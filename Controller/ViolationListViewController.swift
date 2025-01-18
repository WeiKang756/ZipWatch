//
//  ViolationListViewController.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 16/01/2025.
//

import UIKit

protocol ViolationSelectionDelegate: AnyObject {
    func didSelectViolation(_ violation: ViolationData)
}


class ViolationListViewController: UIViewController {
    // MARK: - Properties
    // Inside ViolationListViewController class definition, add:
    private var _isSelectionMode = false
    private weak var _selectionDelegate: ViolationSelectionDelegate?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .systemRed
        button.backgroundColor = .white
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var violations: [ViolationData] = []
    private var filteredViolations: [ViolationData] = []
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
        setupNavigationBar()
        fetchViolations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchViolations()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        title = "Violations"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        addButton.tintColor = .systemRed
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func addButtonTapped() {
        let addVC = AddViolationViewController()
        navigationController?.pushViewController(addVC, animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Violations"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ViolationCell.self, forCellReuseIdentifier: "ViolationCell")
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search violations..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Data Fetching
    private func fetchViolations() {
        Task {
            do {
                let response: [ViolationData] = try await supabase
                    .from("violations")
                    .select()
                    .order("violation_code")
                    .execute()
                    .value
                
                DispatchQueue.main.async { [weak self] in
                    self?.violations = response
                    self?.tableView.reloadData()
                }
            } catch {
                print("Error fetching violations:", error)
                // Show error alert
                let alert = UIAlertController(
                    title: "Error",
                    message: "Failed to fetch violations: \(error.localizedDescription)",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        }
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredViolations = violations.filter { violation in
            return violation.violationCode.lowercased().contains(searchText.lowercased()) ||
                   violation.description.lowercased().contains(searchText.lowercased()) ||
                   violation.section.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension ViolationListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredViolations.count : violations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViolationCell", for: indexPath) as! ViolationCell
        let violation = isSearching ? filteredViolations[indexPath.row] : violations[indexPath.row]
        cell.configure(with: violation)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
}

// MARK: - UISearchResultsUpdating
extension ViolationListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text ?? "")
    }
}

// In ViolationListViewController
extension ViolationListViewController {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let violation = isSearching ? filteredViolations[indexPath.row] : violations[indexPath.row]
        
        // Delete Action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            self?.deleteViolation(violation)
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        
        // Edit Action
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completion) in
            self?.editViolation(violation)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func deleteViolation(_ violation: ViolationData) {
        let alert = UIAlertController(
            title: "Delete Violation",
            message: "Are you sure you want to delete this violation?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            Task {
                do {
                    try await self?.supabase
                        .from("violations")
                        .delete()
                        .eq("id", value: violation.id)
                        .execute()
                    
                    DispatchQueue.main.async {
                        self?.fetchViolations()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    private func editViolation(_ violation: ViolationData) {
        let editVC = AddViolationViewController()
        navigationController?.pushViewController(editVC, animated: true)
    }
}

// Add these properties and methods to your ViolationListViewController
extension ViolationListViewController {
    var isSelectionMode: Bool {
        get { return _isSelectionMode }
        set { _isSelectionMode = newValue }
    }
    
    var selectionDelegate: ViolationSelectionDelegate? {
        get { return _selectionDelegate }
        set { _selectionDelegate = newValue }
    }
    
    // Override tableView didSelectRowAt when in selection mode
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSelectionMode {
            let violation = isSearching ? filteredViolations[indexPath.row] : violations[indexPath.row]
            selectionDelegate?.didSelectViolation(violation)
            navigationController?.popViewController(animated: true)
        }
    }
}
