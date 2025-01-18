//
//  AddParkingSpotViewControllerDelegate.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 15/01/2025.
//
import UIKit

class AddParkingSpotViewController: UIViewController {
    // MARK: - Properties
    private let streetID: Int
    private var addParkingManager = AddParkingManager()
    
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
    
    private let latitudeField = FormFieldView(title: "LATITUDE", placeholder: "Enter latitude (e.g., 6.0161)")
    private let longitudeField = FormFieldView(title: "LONGITUDE", placeholder: "Enter longitude (e.g., 116.1223)")
    private let parkingSpotIDField = FormFieldView(title: "PARKING SPOT ID", placeholder: "Enter parking spot ID")
    
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
        setupKeyboardHandling()
        addParkingManager.delegate = self
    }
    
    // Add these methods to handle keyboard
    private func setupKeyboardHandling() {
        // Add tap gesture to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Add keyboard notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        // Set text field delegates
        latitudeField.textField.delegate = self
        longitudeField.textField.delegate = self
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // Scroll to active text field
        if let activeField = [latitudeField.textField, longitudeField.textField].first(where: { $0.isFirstResponder }) {
            let rect = activeField.convert(activeField.bounds, to: scrollView)
            scrollView.scrollRectToVisible(rect.insetBy(dx: 0, dy: -20), animated: true)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
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
        formCard.addSubview(latitudeField)
        formCard.addSubview(longitudeField)
        formCard.addSubview(addButton)
        formCard.addSubview(parkingSpotIDField)
        formCard.addSubview(typeLabel)
        
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
            parkingSpotIDField.topAnchor.constraint(equalTo: formCard.topAnchor, constant: 20),
            parkingSpotIDField.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            parkingSpotIDField.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -20),

            typeLabel.topAnchor.constraint(equalTo: parkingSpotIDField.bottomAnchor, constant: 20),
            typeLabel.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            
            typeSegmentControl.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 8),
            typeSegmentControl.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            typeSegmentControl.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -20),
            
            latitudeField.topAnchor.constraint(equalTo: typeSegmentControl.bottomAnchor, constant: 20),
            latitudeField.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            latitudeField.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -20),
            
            longitudeField.topAnchor.constraint(equalTo: latitudeField.bottomAnchor, constant: 16),
            longitudeField.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            longitudeField.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -20),
            
            addButton.topAnchor.constraint(equalTo: longitudeField.bottomAnchor, constant: 30),
            addButton.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            addButton.bottomAnchor.constraint(equalTo: formCard.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    // Add this function to your class
    private func validateFields() -> Bool {
        var isValid = true
        
        // Validate parking spot ID
        if parkingSpotIDField.textField.text?.isEmpty ?? true {
            parkingSpotIDField.showError(true)
            isValid = false
        } else if Int(parkingSpotIDField.textField.text ?? "") == nil {
            parkingSpotIDField.showError(true)
            isValid = false
        }
        
        // Validate coordinates
        if latitudeField.textField.text?.isEmpty ?? true {
            latitudeField.showError(true)
            isValid = false
        } else if Double(latitudeField.textField.text ?? "") == nil {
            latitudeField.showError(true)
            isValid = false
        }
        
        if longitudeField.textField.text?.isEmpty ?? true {
            longitudeField.showError(true)
            isValid = false
        } else if Double(longitudeField.textField.text ?? "") == nil {
            longitudeField.showError(true)
            isValid = false
        }
        
        if !isValid {
            showAlert(title: "Error", message: "Please enter valid values")
        }
        
        return isValid
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        guard validateFields() else { return }
        
        let types = ["green", "yellow", "red", "disable"]
        let selectedType = types[typeSegmentControl.selectedSegmentIndex]
        
        guard let parkingSpotIDText = parkingSpotIDField.textField.text,
              let parkingSpotID = Int(parkingSpotIDText),
              let latitudeText = latitudeField.textField.text,
              let longitudeText = longitudeField.textField.text,
              let latitude = Double(latitudeText),
              let longitude = Double(longitudeText) else {
            showAlert(title: "Error", message: "Please enter valid values")
            return
        }
        
        let parkingSpot = ParkingInsertData(
            parkingSpotID: parkingSpotID,
            streetID: streetID,
            latitude: latitude,
            longitude: longitude,
            type: selectedType
        )
        
        addParkingManager.addParkingSpot(parkingSpot: parkingSpot)
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

extension AddParkingSpotViewController: AddParkingManagerDelegate {
    func didAddParkingSpot() {
        DispatchQueue.main.async {
            self.showSuccessAlert()
        }
    }
    
    func didFailAddParkingSpot() {
        DispatchQueue.main.async {
            self.showAlert(title: "Error", message: "Failed to add parking spot")
        }
    }
}

// Add UITextFieldDelegate extension
extension AddParkingSpotViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == latitudeField.textField {
            latitudeField.hideError()
        } else if textField == longitudeField.textField {
            longitudeField.hideError()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == latitudeField.textField {
            longitudeField.textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            addButtonTapped()
        }
        return true
    }
}

