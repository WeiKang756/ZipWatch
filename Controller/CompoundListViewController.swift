//
//  CompoundModel.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 18/01/2025.
//


import UIKit
import Supabase

// MARK: - CompoundListViewController
class CompoundListViewController: UIViewController {
    // MARK: - Properties
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var compounds: [CompoundData] = []
    private var filteredCompounds: [CompoundData] = []
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
        fetchCompounds()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Compounds"
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
        tableView.register(CompoundCell.self, forCellReuseIdentifier: "CompoundCell")
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by plate number..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Data Fetching
    private func fetchCompounds() {
        Task {
            do {
                let compoundData: [CompoundData] = try await supabase
                    .from("compounds")
                    .select("""
                        *,
                        violations!inner(
                            *
                        )
                    """)
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                
                DispatchQueue.main.async { [weak self] in
                    self?.compounds = compoundData
                    self?.tableView.reloadData()
                }
            } catch {
                print("Error fetching compounds:", error)
            }
        }
    }
    
    private func filterContent(for searchText: String) {
        filteredCompounds = compounds.filter { compound in
            return compound.plateNumber.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension CompoundListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let compound = isSearching ? filteredCompounds[indexPath.row] : compounds[indexPath.row]
        
        // Convert CompoundModel to CompoundData
        let compoundData = CompoundData(
            id: compound.id,
            violation: compound.violation,
            location: compound.location,
            status: compound.status,
            paymentDate: compound.paymentDate,
            amountPaid: compound.amountPaid,
            createdAt: compound.createdAt,
            plateNumber: compound.plateNumber
        )
        
        let detailVC = CompoundDetailViewController(compound: compoundData)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredCompounds.count : compounds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompoundCell", for: indexPath) as! CompoundCell
        let compound = isSearching ? filteredCompounds[indexPath.row] : compounds[indexPath.row]
        cell.configure(with: compound)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

// MARK: - UISearchResultsUpdating
extension CompoundListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContent(for: searchController.searchBar.text ?? "")
    }
}

// MARK: - CompoundCell
class CompoundCell: UITableViewCell {
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
    
    private let violationCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(plateNumberLabel)
        containerView.addSubview(violationCodeLabel)
        containerView.addSubview(locationLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(statusContainer)
        statusContainer.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            plateNumberLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            plateNumberLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            violationCodeLabel.topAnchor.constraint(equalTo: plateNumberLabel.bottomAnchor, constant: 4),
            violationCodeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            locationLabel.topAnchor.constraint(equalTo: violationCodeLabel.bottomAnchor, constant: 8),
            locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            statusContainer.centerYAnchor.constraint(equalTo: plateNumberLabel.centerYAnchor),
            statusContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            statusContainer.heightAnchor.constraint(equalToConstant: 24),
            
            statusLabel.topAnchor.constraint(equalTo: statusContainer.topAnchor, constant: 4),
            statusLabel.bottomAnchor.constraint(equalTo: statusContainer.bottomAnchor, constant: -4),
            statusLabel.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor, constant: -12)
        ])
    }
    
    func configure(with compound: CompoundData) {
        plateNumberLabel.text = compound.plateNumber
        violationCodeLabel.text = "Violation: \(compound.violation.violationCode)"
        locationLabel.text = compound.location
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: compound.createdAt)
        
        statusLabel.text = compound.status.uppercased()
        
        // Configure status colors
        switch compound.status.lowercased() {
        case "paid":
            statusContainer.backgroundColor = .systemGreen.withAlphaComponent(0.2)
            statusLabel.textColor = .systemGreen
        case "unpaid":
            statusContainer.backgroundColor = .systemRed.withAlphaComponent(0.2)
            statusLabel.textColor = .systemRed
        default:
            statusContainer.backgroundColor = .systemGray.withAlphaComponent(0.2)
            statusLabel.textColor = .systemGray
        }
    }
}
