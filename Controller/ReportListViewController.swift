//
//  ReportListViewController.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 04/01/2025.
//


import UIKit

class ReportListViewController: UIViewController {
    // MARK: - Properties
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var reports: [ReportData] = []
    private var filteredReports: [ReportData] = []
    private var reportManager = ReportManager()
    
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
        reportManager.delegate = self
        reportManager.fetchReport()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Reports"
        navigationController?.navigationBar.prefersLargeTitles = true
        
//        if let navigationBar = navigationController?.navigationBar {
//            let appearance = UINavigationBarAppearance()
//            appearance.configureWithOpaqueBackground()
//            appearance.backgroundColor = .black
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
        tableView.register(ReportCell.self, forCellReuseIdentifier: "ReportCell")
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search reports..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredReports = reports.filter { report in
            return report.issueType.lowercased().contains(searchText.lowercased()) ||
                   report.description.lowercased().contains(searchText.lowercased()) ||
                   report.status.lowercased().contains(searchText.lowercased()) ||
                   (report.id?.uuidString.lowercased().contains(searchText.lowercased()) ?? false)
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension ReportListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredReports.count : reports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCell", for: indexPath) as! ReportCell
        let report = isSearching ? filteredReports[indexPath.row] : reports[indexPath.row]
        cell.configure(with: report)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let report = isSearching ? filteredReports[indexPath.row] : reports[indexPath.row]
        let detailVC = ReportDetailViewController(report: report)
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}

// MARK: - Search Delegates
extension ReportListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text ?? "")
    }
}

// MARK: - ReportManagerDelegate
extension ReportListViewController: ReportManagerDelegate {
    func didFetchReports(_ reports: [ReportData]) {
        self.reports = reports
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension ReportListViewController: ReportDetailViewControllerDelegate {
    func didUpdateReport() {
        reportManager.fetchReport()
    }
}
