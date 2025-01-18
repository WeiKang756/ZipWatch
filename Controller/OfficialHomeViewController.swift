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
    
    private let actionsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private let actions = [
        ActionItem(title: "Manage Users", description: "View and manage accounts", iconName: "person.fill"),
        ActionItem(title: "View Reports", description: "Check violation reports", iconName: "doc.text.fill"),
        ActionItem(title: "Parking Zones", description: "Manage parking areas", iconName: "map.fill"),
        ActionItem(title: "Analytics", description: "View statistics", iconName: "chart.bar.fill"),
        ActionItem(title: "Transactions", description: "View payment history", iconName: "list.bullet.rectangle.fill"),
        ActionItem(title: "Violation", description: "", iconName: "list.bullet.rectangle.fill")
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
        
        // Add scroll view for content
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add actions collection view to content view
        contentView.addSubview(actionsCollectionView)
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100), // Fixed height for header
            
            welcomeLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            welcomeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            
            logoutButton.centerYAnchor.constraint(equalTo: welcomeLabel.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            logoutButton.widthAnchor.constraint(equalToConstant: 32),
            logoutButton.heightAnchor.constraint(equalToConstant: 32),
                        
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
            
            // Actions Collection View
            actionsCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            actionsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            actionsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            actionsCollectionView.heightAnchor.constraint(equalToConstant: 500)
        ])
    }
    
    private func handleActionSelection(_ action: ActionItem) {
        switch action.title {
        case "Transactions":
            let transactionListVC = TransactionListViewController()
            navigationController?.pushViewController(transactionListVC, animated: true)
            
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
            
        case "Violation":
            let violationsVC = ViolationListViewController()
            navigationController?.pushViewController(violationsVC, animated: true)
            
        default:
            break
        }
    }
    
    private func setupCollectionViews() {
        actionsCollectionView.register(ActionCell.self, forCellWithReuseIdentifier: ActionCell.identifier)
        actionsCollectionView.delegate = self
        actionsCollectionView.dataSource = self
    }
    
    private func setupActions() {
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension OfficialHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActionCell.identifier, for: indexPath) as! ActionCell
        cell.configure(with: actions[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.width - 32
        return CGSize(width: width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let action = actions[indexPath.item]
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Handle the action
        handleActionSelection(action)
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
