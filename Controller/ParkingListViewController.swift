import UIKit
import CoreLocation

class ParkingListViewController: UIViewController {
    // MARK: - Properties
    private let street: StreetModel
    private var addParkingManager = AddParkingManager()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let streetInfoCard: UIView = {
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
    
    private let streetNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let parkingTypesStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let filterControl: UISegmentedControl = {
        let items = ["All", "Available", "Occupied"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var parkingSpots: [ParkingSpotModel] = []
    private var filteredParkingSpots: [ParkingSpotModel] = []
    
    private var isSearching: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    private var searchBarIsEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    // MARK: - Initialization
    init(street: StreetModel) {
        self.street = street
        self.parkingSpots = street.parkingSpots
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupSearchController()
        configureHeaderInfo()
        setupNavigationItem()
        addParkingManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addParkingManager.fetchParkingSpot(streetID: street.streetID)
    }
    
    // MARK: - Setup
    private func setupNavigationItem() {
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addParkingSpotTapped)
        )
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Parking Spots"
        
        view.addSubview(headerView)
        headerView.addSubview(streetInfoCard)
        streetInfoCard.addSubview(streetNameLabel)
        streetInfoCard.addSubview(parkingTypesStackView)
        headerView.addSubview(filterControl)
        view.addSubview(tableView)
        
        // Add parking type views
        let types = [("Green", UIColor.systemGreen), ("Yellow", UIColor.systemYellow),
                    ("Red", UIColor.systemRed), ("Disable", UIColor.systemBlue)]
        
        types.forEach { type, color in
            parkingTypesStackView.addArrangedSubview(createParkingTypeView(type: type, color: color))
        }
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            streetInfoCard.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            streetInfoCard.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            streetInfoCard.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            streetNameLabel.topAnchor.constraint(equalTo: streetInfoCard.topAnchor, constant: 16),
            streetNameLabel.leadingAnchor.constraint(equalTo: streetInfoCard.leadingAnchor, constant: 16),
            
            parkingTypesStackView.topAnchor.constraint(equalTo: streetNameLabel.bottomAnchor, constant: 16),
            parkingTypesStackView.leadingAnchor.constraint(equalTo: streetInfoCard.leadingAnchor, constant: 16),
            parkingTypesStackView.trailingAnchor.constraint(equalTo: streetInfoCard.trailingAnchor, constant: -16),
            parkingTypesStackView.heightAnchor.constraint(equalToConstant: 60),
            parkingTypesStackView.bottomAnchor.constraint(equalTo: streetInfoCard.bottomAnchor, constant: -16),
            
            filterControl.topAnchor.constraint(equalTo: streetInfoCard.bottomAnchor, constant: 16),
            filterControl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            filterControl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            filterControl.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
            
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        filterControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ParkingSpotCell.self, forCellReuseIdentifier: "ParkingSpotCell")
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by ID or type..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func configureHeaderInfo() {
        streetNameLabel.text = street.streetName
        
        if let greenLabel = parkingTypesStackView.arrangedSubviews[0].viewWithTag("Green".hashValue) as? UILabel {
            greenLabel.text = "\(street.numGreen)"
        }
        if let yellowLabel = parkingTypesStackView.arrangedSubviews[1].viewWithTag("Yellow".hashValue) as? UILabel {
            yellowLabel.text = "\(street.numYellow)"
        }
        if let redLabel = parkingTypesStackView.arrangedSubviews[2].viewWithTag("Red".hashValue) as? UILabel {
            redLabel.text = "\(street.numRed)"
        }
        if let disableLabel = parkingTypesStackView.arrangedSubviews[3].viewWithTag("Disable".hashValue) as? UILabel {
            disableLabel.text = "\(street.numDisable)"
        }
    }
    
    private func createParkingTypeView(type: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.1)
        container.layer.cornerRadius = 8
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let typeLabel = UILabel()
        typeLabel.text = type
        typeLabel.font = .systemFont(ofSize: 12)
        typeLabel.textColor = color
        
        let countLabel = UILabel()
        countLabel.font = .systemFont(ofSize: 16, weight: .medium)
        countLabel.textColor = color
        countLabel.tag = type.hashValue
        
        stackView.addArrangedSubview(typeLabel)
        stackView.addArrangedSubview(countLabel)
        
        container.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    @objc private func filterChanged() {
        filterParkingSpots()
    }
    
    @objc private func addParkingSpotTapped() {
        let addParkingSpotVC = AddParkingSpotViewController(streetID: street.streetID)
        navigationController?.pushViewController(addParkingSpotVC, animated: true)
    }

    
    private func filterParkingSpots() {
        var spots = parkingSpots
        
        switch filterControl.selectedSegmentIndex {
        case 1:
            spots = spots.filter { $0.isAvailable }
        case 2:
            spots = spots.filter { !$0.isAvailable }
        default:
            break
        }
        
        // Apply search filter if searching
        if isSearching {
            let searchText = searchController.searchBar.text?.lowercased() ?? ""
            spots = spots.filter { spot in
                return spot.type.lowercased().contains(searchText) ||
                       String(spot.parkingSpotID).contains(searchText)
            }
        }
        
        filteredParkingSpots = spots
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension ParkingListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching || filterControl.selectedSegmentIndex != 0 ?
            filteredParkingSpots.count : parkingSpots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingSpotCell", for: indexPath) as! ParkingSpotCell
        let spot = isSearching || filterControl.selectedSegmentIndex != 0 ?
            filteredParkingSpots[indexPath.row] : parkingSpots[indexPath.row]
        cell.configure(with: spot)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let spot = isSearching || filterControl.selectedSegmentIndex != 0 ?
            filteredParkingSpots[indexPath.row] : parkingSpots[indexPath.row]
        
        // Create and push ParkingDetailViewController
        let detailVC = ParkingDetailViewController(parkingSpot: spot)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let spot = isSearching || filterControl.selectedSegmentIndex != 0 ?
            filteredParkingSpots[indexPath.row] : parkingSpots[indexPath.row]
        
        // Edit action
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completion) in
            guard let streetID = self?.street.streetID else {
                print("dont fetch street id")
                return
            }
            let editSpotVC = EditParkingSpotViewController(parkingSpot: spot, streetID: self?.street.streetID ?? 0)
            editSpotVC.delegate = self
            self?.navigationController?.pushViewController(editSpotVC, animated: true)
            completion(true)
        }
        editAction.backgroundColor = UIColor.systemBlue
        
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            self?.showDeleteConfirmation(for: spot)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    // Add these helper methods
    private func showDeleteConfirmation(for spot: ParkingSpotModel) {
        let alert = UIAlertController(
            title: "Delete Parking Spot",
            message: "Are you sure you want to delete spot #\(spot.parkingSpotID)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteParkingSpot(spot)
        })
        
        present(alert, animated: true)
    }

    private func deleteParkingSpot(_ spot: ParkingSpotModel) {
        Task {
            do {
                try await SupabaseManager.shared.client
                    .from("ParkingSpot")
                    .delete()
                    .eq("parkingSpotID", value: spot.parkingSpotID)
                    .execute()
                
                // Refresh the parking spots
                addParkingManager.fetchParkingSpot(streetID: street.streetID)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.showAlert(title: "Error", message: "Failed to delete parking spot: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension ParkingListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterParkingSpots()
    }
}

extension ParkingListViewController: EditParkingSpotViewControllerDelegate {
    func didUpdateParkingSpot() {
        // Refresh the parking spots
        addParkingManager.fetchParkingSpot(streetID: street.streetID)
    }
}

extension ParkingListViewController: AddParkingManagerDelegate {
    func didFetchParkingSpotData(_ parkingSpotModels: [ParkingSpotModel]){
        parkingSpots = parkingSpotModels
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
