//
//  StreetListViewController.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 07/01/2025.
//


import UIKit
import CoreLocation

class StreetListViewController: UIViewController {
    // MARK: - Properties
    private let areaID: Int
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
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var streets: [StreetModel] = []
    private var filteredStreets: [StreetModel] = []
    private var parkingManager = ParkingManager()
    
    private var isSearching: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    private var searchBarIsEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    // MARK: - Initialization
    init(areaID: Int) {
        self.areaID = areaID
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
        setupMapManager()
        fetchStreets()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Streets"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(StreetCell.self, forCellReuseIdentifier: "StreetCell")
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search streets..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupMapManager() {
        parkingManager.delegate = self
    }
    
    // MARK: - Data Fetching
    private func fetchStreets() {
        loadingIndicator.startAnimating()
        parkingManager.fetchStreetAndParkingSpotData(areaID: areaID)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredStreets = streets.filter { street in
            return street.streetName.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
}

// MARK: - MapManagerDelegate
extension StreetListViewController: ParkingManagerDelegate {
    func didFetchStreetAndParkingSpotData(_ streetsModel: [StreetModel]) {
        DispatchQueue.main.async { [weak self] in
            self?.loadingIndicator.stopAnimating()
            self?.streets = streetsModel
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate & DataSource
extension StreetListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredStreets.count : streets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StreetCell", for: indexPath) as! StreetCell
        let street = isSearching ? filteredStreets[indexPath.row] : streets[indexPath.row]
        cell.configure(with: street)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let street = isSearching ? filteredStreets[indexPath.row] : streets[indexPath.row]
        let parkingListVC = ParkingListViewController(street: street)
        navigationController?.pushViewController(parkingListVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension StreetListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text ?? "")
    }
}

// MARK: - StreetCell
class StreetCell: UITableViewCell {
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
    
    private let streetNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let availabilityContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen.withAlphaComponent(0.1)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let availabilityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGreen
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
        containerView.addSubview(streetNameLabel)
        containerView.addSubview(availabilityContainer)
        availabilityContainer.addSubview(availabilityLabel)
        containerView.addSubview(parkingTypesStackView)
        
        // Add parking type views
        let types = [("Green", UIColor.systemGreen), ("Yellow", UIColor.systemYellow),
                    ("Red", UIColor.systemRed), ("Disable", UIColor.systemBlue)]
        
        types.forEach { type, color in
            parkingTypesStackView.addArrangedSubview(createParkingTypeView(type: type, color: color))
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            streetNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            streetNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            availabilityContainer.centerYAnchor.constraint(equalTo: streetNameLabel.centerYAnchor),
            availabilityContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            availabilityContainer.heightAnchor.constraint(equalToConstant: 28),
            
            availabilityLabel.topAnchor.constraint(equalTo: availabilityContainer.topAnchor, constant: 6),
            availabilityLabel.bottomAnchor.constraint(equalTo: availabilityContainer.bottomAnchor, constant: -6),
            availabilityLabel.leadingAnchor.constraint(equalTo: availabilityContainer.leadingAnchor, constant: 12),
            availabilityLabel.trailingAnchor.constraint(equalTo: availabilityContainer.trailingAnchor, constant: -12),
            
            parkingTypesStackView.topAnchor.constraint(equalTo: streetNameLabel.bottomAnchor, constant: 16),
            parkingTypesStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            parkingTypesStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            parkingTypesStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            parkingTypesStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
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
    
    func configure(with street: StreetModel) {
        streetNameLabel.text = street.streetName
        availabilityLabel.text = "\(street.numAvailable) Available"
        
        // Update parking type counts
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
        
        // Update availability container color based on available spots
        let percentage = Double(street.numAvailable) / Double(street.parkingSpots.count) * 100
        if percentage >= 50 {
            availabilityContainer.backgroundColor = .systemGreen.withAlphaComponent(0.1)
            availabilityLabel.textColor = .systemGreen
        } else if percentage >= 20 {
            availabilityContainer.backgroundColor = .systemYellow.withAlphaComponent(0.1)
            availabilityLabel.textColor = .systemYellow
        } else {
            availabilityContainer.backgroundColor = .systemRed.withAlphaComponent(0.1)
            availabilityLabel.textColor = .systemRed
        }
    }
}
