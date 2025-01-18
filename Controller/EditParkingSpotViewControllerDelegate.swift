//
//  EditParkingSpotViewControllerDelegate.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 16/01/2025.
//
import UIKit

protocol EditParkingSpotViewControllerDelegate: AnyObject {
    func didUpdateParkingSpot()
}

class EditParkingSpotViewController: UIViewController {
    // MARK: - Properties
    private let parkingSpot: ParkingSpotModel
    private let streetID: Int
    private let supabase = SupabaseManager.shared.client
    weak var delegate: EditParkingSpotViewControllerDelegate?
    private var activeTextField: UITextField?
    
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
    
    private let typeSegmentControl: UISegmentedControl = {
        let items = ["Green", "Yellow", "Red", "Disable"]
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let availabilitySwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    private let availabilityLabel: UILabel = {
        let label = UILabel()
        label.text = "Available"
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let updateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update Parking Spot", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Add these new UI components after your existing properties
    private let latitudeField = FormFieldView(title: "LATITUDE", placeholder: "Enter latitude")
    private let longitudeField = FormFieldView(title: "LONGITUDE", placeholder: "Enter longitude")
    
    // MARK: - Initialization
    init(parkingSpot: ParkingSpotModel, streetID: Int) {
        self.parkingSpot = parkingSpot
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
        configureWithParkingSpot()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Edit Parking Spot"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(typeSegmentControl)
        contentView.addSubview(availabilityLabel)
        contentView.addSubview(availabilitySwitch)
        contentView.addSubview(latitudeField)
        contentView.addSubview(longitudeField)
        contentView.addSubview(updateButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            typeSegmentControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            typeSegmentControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            typeSegmentControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            availabilityLabel.topAnchor.constraint(equalTo: typeSegmentControl.bottomAnchor, constant: 20),
            availabilityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            availabilitySwitch.centerYAnchor.constraint(equalTo: availabilityLabel.centerYAnchor),
            availabilitySwitch.leadingAnchor.constraint(equalTo: availabilityLabel.trailingAnchor, constant: 20),
            
            latitudeField.topAnchor.constraint(equalTo: availabilityLabel.bottomAnchor, constant: 20),
            latitudeField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            latitudeField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            longitudeField.topAnchor.constraint(equalTo: latitudeField.bottomAnchor, constant: 16),
            longitudeField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            longitudeField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Update button constraints now connect to longitudeField instead of availabilityLabel
            updateButton.topAnchor.constraint(equalTo: longitudeField.bottomAnchor, constant: 30),
            updateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            updateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            updateButton.heightAnchor.constraint(equalToConstant: 50),
            updateButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
    }
    
    private func configureWithParkingSpot() {
        // Set type segment control
        switch parkingSpot.type.lowercased() {
        case "green": typeSegmentControl.selectedSegmentIndex = 0
        case "yellow": typeSegmentControl.selectedSegmentIndex = 1
        case "red": typeSegmentControl.selectedSegmentIndex = 2
        case "disable": typeSegmentControl.selectedSegmentIndex = 3
        default: break
        }
        
        availabilitySwitch.isOn = parkingSpot.isAvailable
        latitudeField.textField.text = String(parkingSpot.latitude)
        longitudeField.textField.text = String(parkingSpot.longitude)
    }
    
    @objc private func updateButtonTapped() {
        // Validate coordinates
        guard let latitudeText = latitudeField.textField.text,
              let longitudeText = longitudeField.textField.text,
              let latitude = Double(latitudeText),
              let longitude = Double(longitudeText) else {
            showAlert(title: "Error", message: "Please enter valid coordinates")
            return
        }
        
        let types = ["green", "yellow", "red", "disable"]
        let type = types[typeSegmentControl.selectedSegmentIndex]
        let parkingInsert = ParkingInsertData(parkingSpotID: parkingSpot.parkingSpotID, streetID: streetID, latitude: latitude, longitude: longitude, type: type)
        Task {
            do {
                try await supabase
                    .from("ParkingSpot")
                    .update(parkingInsert)
                    .eq("parkingSpotID", value: parkingSpot.parkingSpotID)
                    .execute()
                
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didUpdateParkingSpot()
                    self?.showSuccessAlert()
                }
            } catch {
                showAlert(title: "Error", message: error.localizedDescription)
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
            message: "Parking spot updated successfully",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
