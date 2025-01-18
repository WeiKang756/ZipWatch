import UIKit
import Supabase

protocol ActiveSessionsViewControllerDelegate: AnyObject {
    func didFetchActiveSessions(_ sessions: [ParkingSession])
}

class ActiveSessionsViewController: UIViewController {
    // MARK: - Properties
    private var selectedArea: String? {
        didSet {
            filterSessions()
        }
    }
    
    private let createCompoundButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemRed
        button.setImage(UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No active sessions"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var activeSessions: [ParkingSession] = []
    private var filteredSessions: [ParkingSession] = []
    private let supabase = SupabaseManager.shared.client
    
    private var isSearching: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    private var searchBarIsEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupSearchController()
        setupFilterButton()
        fetchActiveSessions()
        setupActions()
    }
    
    private func setupFilterButton() {
        let barButton = UIBarButtonItem(customView: filterButton)
        navigationItem.rightBarButtonItem = barButton
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    }
    
    @objc private func filterButtonTapped() {
        Task {
            do {
                let areas: [AreaModel] = try await fetchAreas()
                
                DispatchQueue.main.async { [weak self] in
                    self?.showAreaFilterMenu(areas)
                }
            } catch {
                print("Error fetching areas: \(error)")
            }
        }
    }
    
    private func fetchAreas() async throws -> [AreaModel] {
        let areasData: [AreaData] = try await supabase
            .from("Area")
            .select()
            .execute()
            .value
        
        return areasData.map { areaData in
            AreaModel(
                areaID: areaData.areaID,
                areaName: areaData.areaName,
                latitude: areaData.latitude,
                longtitude: areaData.longitude,
                totalParking: areaData.totalParking ?? 0,
                availableParking: areaData.availableParking ?? 0,
                numGreen: 0,
                numYellow: 0,
                numRed: 0,
                numDisable: 0,
                distance: nil
            )
        }
    }
    
    private func showAreaFilterMenu(_ areas: [AreaModel]) {
        let alertController = UIAlertController(title: "Filter by Area", message: nil, preferredStyle: .actionSheet)
        
        // Add "All Areas" option
        alertController.addAction(UIAlertAction(title: "All Areas", style: .default) { [weak self] _ in
            self?.selectedArea = nil
        })
        
        // Add each area as an option
        for area in areas {
            alertController.addAction(UIAlertAction(title: area.areaName, style: .default) { [weak self] _ in
                self?.selectedArea = area.areaName
            })
        }
        
        // Add cancel option
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad support
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = filterButton
            popoverController.sourceRect = filterButton.bounds
        }
        
        present(alertController, animated: true)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Active Sessions"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)
        view.addSubview(createCompoundButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            createCompoundButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createCompoundButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createCompoundButton.widthAnchor.constraint(equalToConstant: 56),
            createCompoundButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ActiveSessionCell.self, forCellReuseIdentifier: "ActiveSessionCell")
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by plate number..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Data Fetching
    private func fetchActiveSessions() {
        loadingIndicator.startAnimating()
        
        Task {
            do {
                let sessions: [ParkingSession] = try await supabase
                    .from("parking_sessions")
                    .select("""
                        *,
                        ParkingSpot:parking_spot_id (
                            parkingSpotID,
                            latitude,
                            longitude,
                            type,
                            isAvailable,
                            Street (
                                streetID,
                                streetName,
                                Area (
                                    areaName
                                )
                            )
                        )
                    """)
                    .eq("status", value: "active")
                    .execute()
                    .value
                
                DispatchQueue.main.async { [weak self] in
                    self?.loadingIndicator.stopAnimating()
                    self?.activeSessions = sessions
                    self?.emptyStateLabel.isHidden = !sessions.isEmpty
                    self?.tableView.reloadData()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.loadingIndicator.stopAnimating()
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func filterSessions() {
        var filteredResults = activeSessions
        
        // Apply area filter if selected
        if let selectedArea = selectedArea {
            filteredResults = filteredResults.filter { session in
                return session.parkingSpot.street.area.areaName == selectedArea
            }
        }
        
        // Apply search text filter if searching
        if isSearching {
            let searchText = searchController.searchBar.text ?? ""
            filteredResults = filteredResults.filter { session in
                return session.plateNumber.lowercased().contains(searchText.lowercased())
            }
        }
        
        filteredSessions = filteredResults
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.emptyStateLabel.isHidden = !filteredResults.isEmpty
        }
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filterSessions()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupActions() {
        createCompoundButton.addTarget(self, action: #selector(createCompoundTapped), for: .touchUpInside)
    }

    @objc private func createCompoundTapped() {
        print("plus tapped")
        let createCompoundVC = AddCompoundViewController()
        let navigationController = UINavigationController(rootViewController: createCompoundVC)
        present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension ActiveSessionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sessions = (isSearching || selectedArea != nil) ? filteredSessions : activeSessions
        emptyStateLabel.isHidden = sessions.count > 0
        return sessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveSessionCell", for: indexPath) as! ActiveSessionCell
        let sessions = (isSearching || selectedArea != nil) ? filteredSessions : activeSessions
        let session = sessions[indexPath.row]
        cell.configure(with: session)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sessions = (isSearching || selectedArea != nil) ? filteredSessions : activeSessions
        let session = sessions[indexPath.row]
        
        let detailVC = SessionDetailViewController(session: session)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension ActiveSessionsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text ?? "")
    }
}

// MARK: - ActiveSessionCell
class ActiveSessionCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let plateNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLeftContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen.withAlphaComponent(0.1)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let timeLeftLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let startTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(plateNumberLabel)
        containerView.addSubview(locationLabel)
        containerView.addSubview(timeLeftContainer)
        timeLeftContainer.addSubview(timeLeftLabel)
        containerView.addSubview(startTimeLabel)
        containerView.addSubview(durationLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            plateNumberLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            plateNumberLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            timeLeftContainer.centerYAnchor.constraint(equalTo: plateNumberLabel.centerYAnchor),
            timeLeftContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            timeLeftLabel.topAnchor.constraint(equalTo: timeLeftContainer.topAnchor, constant: 6),
            timeLeftLabel.bottomAnchor.constraint(equalTo: timeLeftContainer.bottomAnchor, constant: -6),
            timeLeftLabel.leadingAnchor.constraint(equalTo: timeLeftContainer.leadingAnchor, constant: 12),
            timeLeftLabel.trailingAnchor.constraint(equalTo: timeLeftContainer.trailingAnchor, constant: -12),
            
            locationLabel.topAnchor.constraint(equalTo: plateNumberLabel.bottomAnchor, constant: 8),
            locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            startTimeLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            startTimeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            startTimeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            durationLabel.centerYAnchor.constraint(equalTo: startTimeLabel.centerYAnchor),
            durationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with session: ParkingSession) {
        plateNumberLabel.text = session.plateNumber
        locationLabel.text = "Spot #\(session.parkingSpot.parkingSpotID) - \(session.parkingSpot.street.streetName)"
        
        let timeLeft = session.calculateTimeLeft()
        timeLeftLabel.text = timeLeft
        
        if timeLeft == "Expired" {
            timeLeftContainer.backgroundColor = .systemRed.withAlphaComponent(0.1)
            timeLeftLabel.textColor = .systemRed
        } else {
            timeLeftContainer.backgroundColor = .systemGreen.withAlphaComponent(0.1)
            timeLeftLabel.textColor = .systemGreen
        }
        
        startTimeLabel.text = "Started: \(DateFormatterUtility.shared.formatTime(session.startTime))"
        durationLabel.text = "Duration: \(session.duration)"
    }
}
