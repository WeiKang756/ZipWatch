//
//  OfficialHomeViewController.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 03/01/2025.
//


import UIKit

class OfficialHomeViewController: UIViewController {

    //MARK: - Properties
    private var loginManger = LoginManager()
    
    // MARK: - UI Components
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome back, Admin"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search reports, users, or locations..."
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .white
        searchBar.layer.cornerRadius = 10
        searchBar.clipsToBounds = true
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private let actionsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private let stats = [
        StatItem(title: "Total Revenue", value: "RM 125,430", change: "+12.5%", isPositive: true),
        StatItem(title: "Active Sessions", value: "1,234", change: "-3.2%", isPositive: false),
        StatItem(title: "Violations", value: "85", change: "+5.8%", isPositive: false),
        StatItem(title: "Occupancy Rate", value: "78%", change: "+2.1%", isPositive: true)
    ]
    
    private let actions = [
        ActionItem(title: "Manage Users", description: "View and manage accounts", iconName: "person.fill"),
        ActionItem(title: "View Reports", description: "Check violation reports", iconName: "doc.text.fill"),
        ActionItem(title: "Parking Zones", description: "Manage parking areas", iconName: "map.fill"),
        ActionItem(title: "Analytics", description: "View statistics", iconName: "chart.bar.fill")
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loginManger.delegate = self
        setupUI()
        setupCollectionViews()
        setupActions()
    }
    
    //MARK: - Action
    @objc func logoutButtonTapped() {
        loginManger.signOut()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Dashboard"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add subviews
        view.addSubview(headerView)
        headerView.addSubview(welcomeLabel)
        headerView.addSubview(logoutButton)
        headerView.addSubview(searchBar)
        
        // Add scroll view for content
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add collection views to content view
        contentView.addSubview(statsCollectionView)
        contentView.addSubview(actionsCollectionView)
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 160), // Fixed height for header
            
            welcomeLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            welcomeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            
            logoutButton.centerYAnchor.constraint(equalTo: welcomeLabel.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            logoutButton.widthAnchor.constraint(equalToConstant: 32),
            logoutButton.heightAnchor.constraint(equalToConstant: 32),
            
            searchBar.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 16),
            searchBar.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 44),
            
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Collection Views
            statsCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            statsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statsCollectionView.heightAnchor.constraint(equalToConstant: 130),
            
            actionsCollectionView.topAnchor.constraint(equalTo: statsCollectionView.bottomAnchor, constant: 24),
            actionsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            actionsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            actionsCollectionView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
    
    private func handleActionSelection(_ action: ActionItem) {
        switch action.title {
        case "Manage Users":
            let cityOfficialVC = CreateOfficialAccountViewController()
            navigationController?.pushViewController(cityOfficialVC, animated: true)
            
        case "View Reports":
            let vc = ReportListViewController()
            navigationController?.pushViewController(vc, animated: true)
            
        case "Parking Zones":
            let vc = OfficialListViewController()
            navigationController?.pushViewController(vc, animated: true)

            
        case "Analytics":
            let vc = AreaListViewController()
            navigationController?.pushViewController(vc, animated: true)
            
        default:
            break
        }
    }
    
    private func setupCollectionViews() {
        statsCollectionView.register(StatCell.self, forCellWithReuseIdentifier: StatCell.identifier)
        actionsCollectionView.register(ActionCell.self, forCellWithReuseIdentifier: ActionCell.identifier)
        
        statsCollectionView.delegate = self
        statsCollectionView.dataSource = self
        actionsCollectionView.delegate = self
        actionsCollectionView.dataSource = self
    }
    
    private func setupActions() {
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension OfficialHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == statsCollectionView ? stats.count : actions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == statsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatCell.identifier, for: indexPath) as! StatCell
            cell.configure(with: stats[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActionCell.identifier, for: indexPath) as! ActionCell
            cell.configure(with: actions[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == statsCollectionView {
            return CGSize(width: 200, height: 100)
        } else {
            let width = (view.bounds.width - 48) / 2
            return CGSize(width: width, height: 100)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == actionsCollectionView {
            let action = actions[indexPath.item]
            
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            // Handle the action
            handleActionSelection(action)
        }
    }
}

extension OfficialHomeViewController: LoginManagerDelegate {
    func didSignOut() {
        DispatchQueue.main.async {
            let loginVC = LoginViewController()
            let navigationController = UINavigationController(rootViewController: loginVC)
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return
            }
            
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
            
            UIView.transition(with: window,
                             duration: 0.5,
                             options: [.transitionCrossDissolve],
                             animations: nil,
                             completion: nil)
        }
    }
}



#Preview {
    OfficialHomeViewController()
}
