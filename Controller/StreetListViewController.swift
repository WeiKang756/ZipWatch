//
//  StreetListViewController.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 07/01/2025.

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
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "road.lanes")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No Streets Available"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStateDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap + to add a new street"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var streets: [StreetModel] = []
    private var filteredStreets: [StreetModel] = []
    private var parkingManager = ParkingManager()
    private var userRole: String?
    
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
        fetchUserRoleAndData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchStreets()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Streets"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add button in navigation bar
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.rightBarButtonItem = addButton
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        // Add empty state view
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateView.addSubview(emptyStateDescriptionLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 60),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 60),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            emptyStateDescriptionLabel.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 8),
            emptyStateDescriptionLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateDescriptionLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateDescriptionLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
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
    
    private func updateEmptyState() {
        emptyStateView.isHidden = !streets.isEmpty
        tableView.isHidden = streets.isEmpty
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        guard userRole == "city_official" else {
            showAlert(title: "Permission Denied", message: "Only city officials can add streets.")
            return
        }
        
        let addStreetVC = AddStreetViewController(areaID: areaID)
        navigationController?.pushViewController(addStreetVC, animated: true)
    }
    
    // MARK: - Data Fetching
    private func fetchUserRoleAndData() {
            loadingIndicator.startAnimating()
            
            Task {
                do {
                    // Fetch user role
                    userRole = try await SupabaseManager.shared.getCurrentUserRole()
                    print("User role: \(userRole ?? "Unknown")")
                    
                    // Fetch streets after determining the role
                    fetchStreets()
                    
                    // Configure UI based on user role
                    DispatchQueue.main.async {
                        self.configureRoleBasedUI()
                    }
                } catch {
                    print("Error fetching user role: \(error.localizedDescription)")
                }
            }
        }
    
    private func configureRoleBasedUI() {
        // Disable "Add" button for non-city-official users
        if userRole != "city_official" {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
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
            guard let self = self else { return }
            self.loadingIndicator.stopAnimating()
            
            if streetsModel.isEmpty {
                // Handle empty state
                self.streets = []
                self.emptyStateView.isHidden = false
                self.tableView.isHidden = true
                
                // You can also customize the empty state message
                self.emptyStateLabel.text = "No Streets Available"
                self.emptyStateDescriptionLabel.text = "Tap + to add a new street"
            } else {
                // Handle data state
                self.streets = streetsModel
                self.emptyStateView.isHidden = true
                self.tableView.isHidden = false
            }
            
            self.tableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let street = isSearching ? filteredStreets[indexPath.row] : streets[indexPath.row]
        
        // Edit action
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completion) in
            guard self?.userRole == "city_official" else {
                self?.showAlert(title: "Permission Denied", message: "Only city officials can delete streets.")
                return
            }
            
            let editStreetVC = EditStreetViewController(street: street)
            editStreetVC.delegate = self
            self?.navigationController?.pushViewController(editStreetVC, animated: true)
            completion(true)
        }
        editAction.backgroundColor = UIColor.systemBlue
        
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            self?.showDeleteConfirmation(for: street)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    // Add these helper methods
    private func showDeleteConfirmation(for street: StreetModel) {
        guard userRole == "city_official" else {
            showAlert(title: "Permission Denied", message: "Only city officials can delete streets.")
            return
        }
        
        let alert = UIAlertController(
            title: "Delete Street",
            message: "Are you sure you want to delete \(street.streetName)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteStreet(street)
        })
        
        present(alert, animated: true)
    }

    private func deleteStreet(_ street: StreetModel) {
        Task {
            do {
                try await SupabaseManager.shared.client
                    .from("Street")
                    .delete()
                    .eq("streetID", value: street.streetID)
                    .execute()
                
                // Refresh the data
                fetchStreets()
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.showAlert(title: "Error", message: "Failed to delete street: \(error.localizedDescription)")
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
extension StreetListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text ?? "")
    }
}

extension StreetListViewController: EditStreetViewControllerDelegate {
    func didUpdateStreet() {
        fetchStreets()
    }
}
