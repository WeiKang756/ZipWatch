//
//  EnforcementHomeViewController.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 13/01/2025.
//


import UIKit

class EnforcementHomeViewController: UIViewController {
    // MARK: - Properties
    private var loginManager = LoginManager()
    
    // MARK: - UI Components
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome back, Officer"
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
        StatItem(title: "Active Sessions", value: "847", change: "+5.2%", isPositive: true),
        StatItem(title: "Current Occupancy", value: "76%", change: "+3.8%", isPositive: true),
        StatItem(title: "Pending Reports", value: "12", change: "-25%", isPositive: true),
        StatItem(title: "Daily Violations", value: "28", change: "+12%", isPositive: false)
    ]
    
    private let actions = [
        ActionItem(title: "Active Sessions", description: "View current parking sessions", iconName: "car.fill"),
        ActionItem(title: "View Reports", description: "Check violation reports", iconName: "doc.text.fill"),
        ActionItem(title: "Parking Zones", description: "Monitor parking areas", iconName: "map.fill"),
        ActionItem(title: "Compound", description: "View Compound", iconName: "chart.bar.fill")
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loginManager.delegate = self
        setupUI()
        setupCollectionViews()
        setupActions()
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
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(statsCollectionView)
        contentView.addSubview(actionsCollectionView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            welcomeLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            welcomeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            
            logoutButton.centerYAnchor.constraint(equalTo: welcomeLabel.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            logoutButton.widthAnchor.constraint(equalToConstant: 32),
            logoutButton.heightAnchor.constraint(equalToConstant: 32),
            
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            statsCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            statsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statsCollectionView.heightAnchor.constraint(equalToConstant: 130),
            
            actionsCollectionView.topAnchor.constraint(equalTo: statsCollectionView.bottomAnchor, constant: 24),
            actionsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            actionsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            actionsCollectionView.heightAnchor.constraint(equalToConstant: 500)
        ])
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
    
    @objc private func logoutButtonTapped() {
        loginManager.signOut()
    }
    
    private func handleActionSelection(_ action: ActionItem) {
        switch action.title {
        case "Active Sessions":
            let vc = ActiveSessionsViewController()
            navigationController?.pushViewController(vc, animated: true)
            break
            
        case "View Reports":
            let vc = ReportListViewController()
            navigationController?.pushViewController(vc, animated: true)
            
        case "Parking Zones":
            let vc = AreaListViewController()
            navigationController?.pushViewController(vc, animated: true)
            
        case "Compound":
            let vc = CompoundListViewController()
            navigationController?.pushViewController(vc, animated: true)
            break
            
        default:
            break
        }
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension EnforcementHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
            let width = view.bounds.width - 32
            return CGSize(width: width, height: 100)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == actionsCollectionView {
            let action = actions[indexPath.item]
            
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            handleActionSelection(action)
        }
    }
}

// MARK: - LoginManagerDelegate
extension EnforcementHomeViewController: LoginManagerDelegate {
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
    EnforcementHomeViewController()
}
