//
//  AddParkingSpotViewControllerDelegate.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 15/01/2025.
//


import UIKit

protocol AddParkingSpotViewControllerDelegate: AnyObject {
    func didAddParkingSpot()
}

class AddParkingSpotViewController: UIViewController {
    // MARK: - Properties
    private let streetID: Int
    private let supabase = SupabaseManager.shared.client
    weak var delegate: AddParkingSpotViewControllerDelegate?
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Add New Parking Spot"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter parking spot details below"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let formCard: UIView = {
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
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "PARKING TYPE"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeSegmentControl: UISegmentedControl = {
        let items = ["Green", "Yellow", "Red", "Disable"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.backgroundColor = .systemBackground
        control.selectedSegmentTintColor = .systemRed
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Parking Spot", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    init(streetID: Int) {
        self.streetID = streetID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(headerLabel)
        headerView.addSubview(descriptionLabel)
        
        contentView.addSubview(formCard)
        formCard.addSubview(typeLabel)
        formCard.addSubview(typeSegmentControl)
        formCard.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 120),
            
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            formCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            formCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            formCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            formCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            typeLabel.topAnchor.constraint(equalTo: formCard.topAnchor, constant: 20),
            typeLabel.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            
            typeSegmentControl.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 8),
            typeSegmentControl.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            typeSegmentControl.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -20),
            
            addButton.topAnchor.constraint(equalTo: typeSegmentControl.bottomAnchor, constant: 30),
            addButton.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            addButton.bottomAnchor.constraint(equalTo: formCard.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        let types = ["green", "yellow", "red", "disable"]
        let selectedType = types[typeSegmentControl.selectedSegmentIndex]
        
        Task {
            do {
                try await supabase
                    .from("ParkingSpot")
                    .insert([
                        "type": selectedType,
                        "isAvailable": true,
                        "streetID": streetID
                    ])
                    .execute()
                
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didAddParkingSpot()
                    self?.showSuccessAlert()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Success",
            message: "Parking spot added successfully",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}