//
//  AreaListViewController.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 07/01/2025.
//


import UIKit
import CoreLocation

class AreaListViewController: UIViewController {
    // MARK: - Properties
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
    private var areas: [AreaModel] = []
    private var filteredAreas: [AreaModel] = []
    private var parkingManager = ParkingManager()
    private var userRole: String?
    
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
        setupMapManager()
        fetchAreas()
        fetchUserRoleAndData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Parking Areas"
        navigationController?.navigationBar.prefersLargeTitles = true
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.rightBarButtonItem = addButton
        
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
        tableView.register(AreaCell.self, forCellReuseIdentifier: "AreaCell")
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by area name..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupMapManager() {
        parkingManager.delegate = self
    }
    
    // MARK: - Data Fetching
    private func fetchUserRoleAndData() {
            loadingIndicator.startAnimating()
            
            Task {
                do {
                    // Fetch user role
                    userRole = try await SupabaseManager.shared.getCurrentUserRole()
                    print("User role: \(userRole ?? "Unknown")")
                    
                    // Fetch areas after determining the role
                    fetchAreas()
                    
                    // Configure UI based on user role
                    DispatchQueue.main.async {
                        self.configureRoleBasedUI()
                    }
                } catch {
                    print("Error fetching user role: \(error.localizedDescription)")
                }
            }
        }
        
    private func fetchAreas() {
        loadingIndicator.startAnimating()
        parkingManager.fetchAreaData()
    }
    
    private func configureRoleBasedUI() {
        // Disable "Add" button for non-city-official users
        if userRole != "city_official" {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredAreas = areas.filter { area in
            return area.areaName.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    private func showDeleteConfirmation(for area: AreaModel) {
        guard userRole == "city_official" else {
            showAlert(title: "Permission Denied", message: "Only city officials can delete areas.")
            return
        }
        
        let alert = UIAlertController(
            title: "Delete Area",
            message: "Are you sure you want to delete \(area.areaName)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteArea(area)
        })
        
        present(alert, animated: true)
    }

    private func deleteArea(_ area: AreaModel) {
        Task {
            do {
                try await SupabaseManager.shared.client
                    .from("Area")
                    .delete()
                    .eq("areaID", value: area.areaID)
                    .execute()
                
                // Refresh the data
                fetchAreas()
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.showAlert(title: "Error", message: "Failed to delete area: \(error.localizedDescription)")
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

// MARK: - MapManagerDelegate
extension AreaListViewController: ParkingManagerDelegate {
    func didFetchAreaData(_ areasModel: [AreaModel]) {
        DispatchQueue.main.async { [weak self] in
            self?.loadingIndicator.stopAnimating()
            self?.areas = areasModel
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate & DataSource
extension AreaListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredAreas.count : areas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AreaCell", for: indexPath) as! AreaCell
        let area = isSearching ? filteredAreas[indexPath.row] : areas[indexPath.row]
        cell.configure(with: area)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let area = isSearching ? filteredAreas[indexPath.row] : areas[indexPath.row]
        let streetListVC = StreetListViewController(areaID: area.areaID)
        navigationController?.pushViewController(streetListVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let area = isSearching ? filteredAreas[indexPath.row] : areas[indexPath.row]
        
        // Edit action
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completion) in
            guard self?.userRole == "city_official" else {
                self?.showAlert(title: "Permission Denied", message: "Only city officials can edit areas.")
                completion(false)
                return
            }
            
            let editAreaVC = EditAreaViewController(area: area)
            editAreaVC.delegate = self
            self?.navigationController?.pushViewController(editAreaVC, animated: true)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            self?.showDeleteConfirmation(for: area)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

// MARK: - UISearchResultsUpdating
extension AreaListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text ?? "")
    }
}

// MARK: - AreaCell
class AreaCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let areaNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let parkingInfoContainer: UIView = {
        let view = UIStackView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let availableLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
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
        containerView.addSubview(areaNameLabel)
        containerView.addSubview(distanceLabel)
        containerView.addSubview(parkingInfoContainer)
        parkingInfoContainer.addSubview(availableLabel)
        parkingInfoContainer.addSubview(totalLabel)
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
            
            areaNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            areaNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            parkingInfoContainer.topAnchor.constraint(equalTo: areaNameLabel.bottomAnchor, constant: 12),
            parkingInfoContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            availableLabel.topAnchor.constraint(equalTo: parkingInfoContainer.topAnchor),
            availableLabel.leadingAnchor.constraint(equalTo: parkingInfoContainer.leadingAnchor),
            
            totalLabel.topAnchor.constraint(equalTo: availableLabel.bottomAnchor, constant: 4),
            totalLabel.leadingAnchor.constraint(equalTo: parkingInfoContainer.leadingAnchor),
            totalLabel.bottomAnchor.constraint(equalTo: parkingInfoContainer.bottomAnchor),
            
            parkingTypesStackView.topAnchor.constraint(equalTo: parkingInfoContainer.bottomAnchor, constant: 12),
            parkingTypesStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            parkingTypesStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            parkingTypesStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            parkingTypesStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func createParkingTypeView(type: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.1)
        container.layer.cornerRadius = 8
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let typeLabel = UILabel()
        typeLabel.text = type
        typeLabel.font = .systemFont(ofSize: 12)
        typeLabel.textColor = color
        
        let countLabel = UILabel()
        countLabel.font = .systemFont(ofSize: 14, weight: .medium)
        countLabel.textColor = color
        countLabel.tag = type.hashValue // Use tag to update count later
        
        stackView.addArrangedSubview(typeLabel)
        stackView.addArrangedSubview(countLabel)
        
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    func configure(with area: AreaModel) {
        areaNameLabel.text = area.areaName
        
        availableLabel.text = "\(area.availableParking ?? 0) Available"
        totalLabel.text = "Total: \(area.totalParking ?? 0)"
        
        // Update parking type counts
        if let greenLabel = parkingTypesStackView.arrangedSubviews[0].viewWithTag("Green".hashValue) as? UILabel {
            greenLabel.text = "\(area.numGreen ?? 0)"
        }
        if let yellowLabel = parkingTypesStackView.arrangedSubviews[1].viewWithTag("Yellow".hashValue) as? UILabel {
            yellowLabel.text = "\(area.numYellow ?? 0)"
        }
        if let redLabel = parkingTypesStackView.arrangedSubviews[2].viewWithTag("Red".hashValue) as? UILabel {
            redLabel.text = "\(area.numRed ?? 0)"
        }
        if let disableLabel = parkingTypesStackView.arrangedSubviews[3].viewWithTag("Disable".hashValue) as? UILabel {
            disableLabel.text = "\(area.numDisable ?? 0)"
        }
    }
}

extension AreaListViewController {
    @objc private func addButtonTapped() {
        guard userRole == "city_official" else {
            showAlert(title: "Permission Denied", message: "Only city officials can add areas.")
            return
        }
        
        let addAreaVC = AddAreaViewController()
        navigationController?.pushViewController(addAreaVC, animated: true)
    }
}

extension AreaListViewController: EditAreaViewControllerDelegate {
    func didUpdateArea() {
        fetchAreas()
    }
}
