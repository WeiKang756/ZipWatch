class ViolationListViewController: UIViewController {
    // MARK: - Properties
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
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
        fetchViolations()
    }
    
    // MARK: - Setup
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