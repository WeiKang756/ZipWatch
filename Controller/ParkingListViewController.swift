import UIKit
import CoreLocation

class ParkingListViewController: UIViewController {
    // MARK: - Properties
    private let street: StreetModel
    
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
    }
    
    // MARK: - Setup
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
}

// MARK: - UISearchResultsUpdating
extension ParkingListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterParkingSpots()
    }
}

// MARK: - ParkingSpotCell
class ParkingSpotCell: UITableViewCell {
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
    
    private let spotIdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if animated {
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
                self.containerView.backgroundColor = highlighted ? .systemGray6 : .white
            }
        } else {
            containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            containerView.backgroundColor = highlighted ? .systemGray6 : .white
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if animated {
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = selected ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
                self.containerView.backgroundColor = selected ? .systemGray6 : .white
            }
        } else {
            containerView.transform = selected ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            containerView.backgroundColor = selected ? .systemGray6 : .white
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(spotIdLabel)
        containerView.addSubview(typeLabel)
        containerView.addSubview(statusContainer)
        statusContainer.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            spotIdLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            spotIdLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            typeLabel.topAnchor.constraint(equalTo: spotIdLabel.bottomAnchor, constant: 4),
            typeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            statusContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            statusContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            statusContainer.heightAnchor.constraint(equalToConstant: 28),
            
            statusLabel.topAnchor.constraint(equalTo: statusContainer.topAnchor, constant: 6),
            statusLabel.bottomAnchor.constraint(equalTo: statusContainer.bottomAnchor, constant: -6),
            statusLabel.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor, constant: -12)
        ])
    }
    
    func configure(with spot: ParkingSpotModel) {
        spotIdLabel.text = "Spot #\(spot.parkingSpotID)"
        typeLabel.text = "Type: \(spot.type.capitalized)"
        
        statusLabel.text = spot.isAvailable ? "AVAILABLE" : "OCCUPIED"
        
        // Configure status style based on availability
        if spot.isAvailable {
            statusContainer.backgroundColor = .systemGreen.withAlphaComponent(0.1)
            statusLabel.textColor = .systemGreen
        } else {
            statusContainer.backgroundColor = .systemRed.withAlphaComponent(0.1)
            statusLabel.textColor = .systemRed
        }
        
        // Configure container style based on type
        switch spot.type.lowercased() {
        case "green":
            containerView.layer.borderColor = UIColor.systemGreen.cgColor
            typeLabel.textColor = .systemGreen
        case "yellow":
            containerView.layer.borderColor = UIColor.systemYellow.cgColor
            typeLabel.textColor = .systemYellow
        case "red":
            containerView.layer.borderColor = UIColor.systemRed.cgColor
            typeLabel.textColor = .systemRed
        case "disable":
            containerView.layer.borderColor = UIColor.systemBlue.cgColor
            typeLabel.textColor = .systemBlue
        default:
            containerView.layer.borderColor = UIColor.clear.cgColor
            typeLabel.textColor = .secondaryLabel
        }
        containerView.layer.borderWidth = 1
    }
}
