//
//  OfficialListViewController.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 06/01/2025.
//


import UIKit
import Supabase

class OfficialListViewController: UIViewController {
    // MARK: - Properties
    private let segmentedControl: UISegmentedControl = {
        let items = ["City Officials", "Enforcement Officers"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.backgroundColor = .systemBackground
        control.selectedSegmentTintColor = .systemRed
        control.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
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
    
    private let searchController = UISearchController(searchResultsController: nil)
    let officialManager = OfficialManager()
    private var cityOfficials: [Official] = []
    private var enforcementOfficials: [Official] = []
    private var filteredCityOfficials: [Official] = []
    private var filteredEnforcementOfficials: [Official] = []
    
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
        setupOfficialManager()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 32),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Officials"
        navigationController?.navigationBar.prefersLargeTitles = true
        
//        if let navigationBar = navigationController?.navigationBar {
//            let appearance = UINavigationBarAppearance()
//            appearance.configureWithOpaqueBackground()
//            appearance.backgroundColor = .systemRed
//            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
//            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//            
//            navigationBar.standardAppearance = appearance
//            navigationBar.scrollEdgeAppearance = appearance
//            navigationBar.compactAppearance = appearance
//        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OfficialCell.self, forCellReuseIdentifier: "OfficialCell")
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by name or ID..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupOfficialManager() {
        officialManager.delegate = self
    }
    
    // MARK: - Actions
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    // MARK: - Data Fetching
    private func fetchData() {
        loadingIndicator.startAnimating()
        officialManager.fetchCityOfficials()
        officialManager.fetchEnforcementOfficials()
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredCityOfficials = cityOfficials.filter { official in
            return official.name.lowercased().contains(searchText.lowercased()) ||
                   official.officialId.lowercased().contains(searchText.lowercased())
        }
        
        filteredEnforcementOfficials = enforcementOfficials.filter { official in
            return official.name.lowercased().contains(searchText.lowercased()) ||
                   official.officialId.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension OfficialListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return segmentedControl.selectedSegmentIndex == 0 ? filteredCityOfficials.count : filteredEnforcementOfficials.count
        }
        return segmentedControl.selectedSegmentIndex == 0 ? cityOfficials.count : enforcementOfficials.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OfficialCell", for: indexPath) as! OfficialCell
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let official = isSearching ? filteredCityOfficials[indexPath.row] : cityOfficials[indexPath.row]
            cell.configure(with: official)
        } else {
            let official = isSearching ? filteredEnforcementOfficials[indexPath.row] : enforcementOfficials[indexPath.row]
            cell.configure(with: official)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let official = segmentedControl.selectedSegmentIndex == 0 ?
            (isSearching ? filteredCityOfficials[indexPath.row] : cityOfficials[indexPath.row]) :
            (isSearching ? filteredEnforcementOfficials[indexPath.row] : enforcementOfficials[indexPath.row])
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Edit action
        let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
            let editVC = EditOfficialViewController(official: official)
            editVC.delegate = self
            self?.navigationController?.pushViewController(editVC, animated: true)
        }
        
        // Delete action
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.showDeleteConfirmation(for: official)
        }
        
        // Only show segment change option if official is in different segment
        let currentSegment = self.segmentedControl.selectedSegmentIndex == 0 ? "city_official" : "enforcement_official"
        if official.type != currentSegment {
            let changeTypeAction = UIAlertAction(title: "Move to \(self.segmentedControl.selectedSegmentIndex == 0 ? "City Officials" : "Enforcement Officers")", style: .default) { [weak self] _ in
                self?.changeOfficialType(official)
            }
            alertController.addAction(changeTypeAction)
        }
        
        alertController.addAction(editAction)
        alertController.addAction(deleteAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func showDeleteConfirmation(for official: Official) {
        let alert = UIAlertController(
            title: "Delete Official",
            message: "Are you sure you want to delete \(official.name)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteOfficial(official)
        })
        
        present(alert, animated: true)
    }

    private func deleteOfficial(_ official: Official) {
        Task {
            do {
                try await SupabaseManager.shared.client
                    .from("officials")
                    .delete()
                    .eq("id", value: official.id)
                    .execute()
                
                // Refresh data after deletion
                officialManager.fetchCityOfficials()
                officialManager.fetchEnforcementOfficials()
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.showError("Failed to delete official: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func changeOfficialType(_ official: Official) {
        let newType = segmentedControl.selectedSegmentIndex == 0 ? "city_official" : "enforcement_official"
        
        Task {
            do {
                try await SupabaseManager.shared.client
                    .from("officials")
                    .update(["type": newType])
                    .eq("id", value: official.id)
                    .execute()
                
                // Refresh data after type change
                officialManager.fetchCityOfficials()
                officialManager.fetchEnforcementOfficials()
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.showError("Failed to change official type: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}

// MARK: - UISearchResultsUpdating
extension OfficialListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text ?? "")
    }
}

// MARK: - OfficialManagerDelegate
extension OfficialListViewController: OfficialManagerDelegate {
    func didFetchCityOfficials(_ officials: [Official]) {
        cityOfficials = officials
        tableView.reloadData()
        loadingIndicator.stopAnimating()
    }
    
    func didFetchEnforcementOfficials(_ officials: [Official]) {
        enforcementOfficials = officials
        tableView.reloadData()
        loadingIndicator.stopAnimating()
    }
    
    func didFailWithError(_ error: Error) {
        loadingIndicator.stopAnimating()
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to fetch officials: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
