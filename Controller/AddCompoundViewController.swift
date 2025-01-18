//
//  AddCompoundViewController.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 18/01/2025.
//
import UIKit
class AddCompoundViewController: UIViewController {
    // MARK: - Properties
    private let supabase = SupabaseManager.shared.client
    private var selectedViolation: ViolationData?
    private var compoundManager = CompoundManager()
    
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "New Compound"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let violationSelectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let violationLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Violation"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectedViolationLabel: UILabel = {
        let label = UILabel()
        label.text = "No violation selected"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectViolationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select", for: .normal)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let plateNumberField = FormFieldView(title: "PLATE NUMBER", placeholder: "Enter vehicle plate number")
    private var activeTextField: UITextField?
    
    
    private let locationSelectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Location"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let selectedLocationLabel: UILabel = {
        let label = UILabel()
        label.text = "No location selected"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let selectLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select", for: .normal)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var selectedArea: AreaModel? {
        didSet {
            selectedLocationLabel.text = selectedArea?.areaName ?? "No location selected"
        }
    }
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Compound", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var parkingManager = ParkingManager()
    
    // Date picker for due date
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.minimumDate = Date()
        return picker
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupKeyboardHandling()
        parkingManager.delegate = self
        compoundManager.delegate = self
    }
    
    // MARK: - Setup
    private func setupKeyboardHandling() {
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
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
        
        // Set text field delegate
        plateNumberField.textField.delegate = self
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let activeField = activeTextField else { return }
        
        let bottomOfTextField = activeField.convert(activeField.bounds, to: view).maxY
        let topOfKeyboard = view.frame.height - keyboardSize.height
        
        // Calculate if the active text field is hidden by keyboard
        if bottomOfTextField > topOfKeyboard {
            let scrollPoint = bottomOfTextField - topOfKeyboard + 20 // 20 points of padding
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollPoint), animated: true)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.setContentOffset(.zero, animated: true)
    }

    // Clean up notifications when view is deallocated
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "New Compound"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(titleLabel)
        
        contentView.addSubview(violationSelectionView)
        violationSelectionView.addSubview(violationLabel)
        violationSelectionView.addSubview(selectedViolationLabel)
        violationSelectionView.addSubview(selectViolationButton)
        
        contentView.addSubview(violationSelectionView)
        contentView.addSubview(plateNumberField)
        contentView.addSubview(locationSelectionView)
        locationSelectionView.addSubview(locationLabel)
        locationSelectionView.addSubview(selectedLocationLabel)
        locationSelectionView.addSubview(selectLocationButton)
        contentView.addSubview(createButton)
        
        
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
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            
            violationSelectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            violationSelectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            violationSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            violationLabel.topAnchor.constraint(equalTo: violationSelectionView.topAnchor, constant: 16),
            violationLabel.leadingAnchor.constraint(equalTo: violationSelectionView.leadingAnchor, constant: 16),
            
            selectedViolationLabel.topAnchor.constraint(equalTo: violationLabel.bottomAnchor, constant: 8),
            selectedViolationLabel.leadingAnchor.constraint(equalTo: violationSelectionView.leadingAnchor, constant: 16),
            selectedViolationLabel.trailingAnchor.constraint(equalTo: selectViolationButton.leadingAnchor, constant: -16),
            selectedViolationLabel.bottomAnchor.constraint(equalTo: violationSelectionView.bottomAnchor, constant: -16),
            
            selectViolationButton.centerYAnchor.constraint(equalTo: selectedViolationLabel.centerYAnchor),
            selectViolationButton.trailingAnchor.constraint(equalTo: violationSelectionView.trailingAnchor, constant: -16),
            selectViolationButton.widthAnchor.constraint(equalToConstant: 80),
            
            plateNumberField.topAnchor.constraint(equalTo: violationSelectionView.bottomAnchor, constant: 24),
            plateNumberField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            plateNumberField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            locationSelectionView.topAnchor.constraint(equalTo: plateNumberField.bottomAnchor, constant: 24),
            locationSelectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            locationLabel.topAnchor.constraint(equalTo: locationSelectionView.topAnchor, constant: 16),
            locationLabel.leadingAnchor.constraint(equalTo: locationSelectionView.leadingAnchor, constant: 16),

            selectedLocationLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            selectedLocationLabel.leadingAnchor.constraint(equalTo: locationSelectionView.leadingAnchor, constant: 16),
            selectedLocationLabel.trailingAnchor.constraint(equalTo: selectLocationButton.leadingAnchor, constant: -16),
            selectedLocationLabel.bottomAnchor.constraint(equalTo: locationSelectionView.bottomAnchor, constant: -16),

            selectLocationButton.centerYAnchor.constraint(equalTo: selectedLocationLabel.centerYAnchor),
            selectLocationButton.trailingAnchor.constraint(equalTo: locationSelectionView.trailingAnchor, constant: -16),
            selectLocationButton.widthAnchor.constraint(equalToConstant: 80),

            createButton.topAnchor.constraint(equalTo: locationSelectionView.bottomAnchor, constant: 32),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 50),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupActions() {
        selectViolationButton.addTarget(self, action: #selector(selectViolationTapped), for: .touchUpInside)
        selectLocationButton.addTarget(self, action: #selector(selectLocationTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    @objc private func selectViolationTapped() {
        // Navigate to violation selection
        let violationListVC = ViolationListViewController()
        violationListVC.selectionDelegate = self
        violationListVC.isSelectionMode = true
        navigationController?.pushViewController(violationListVC, animated: true)
    }
        
    @objc private func createButtonTapped() {
        // Validate fields before proceeding
        guard validateFields() else { return }

        // Retrieve the required data
        guard let violationId = selectedViolation?.id else {
            showAlert(title: "Error", message: "Violation is not selected")
            return
        }
        
        guard let plateNumber = plateNumberField.textField.text, !plateNumber.isEmpty else {
            showAlert(title: "Error", message: "Please enter a valid plate number")
            return
        }
        
        guard let location = selectedArea?.areaName else {
            showAlert(title: "Error", message: "Location is not selected")
            return
        }

        // Create the CompoundData object
        let compoundData = CompoundInsertData(violationId: violationId, plateNumber: plateNumber, location: location)

        // Call the compound manager to create the compound
        compoundManager.createCompound(compoundData: compoundData)
    }


    @objc private func selectLocationTapped() {
        parkingManager.fetchAreaData()
    }

    private func showAreaSelectionMenu(_ areas: [AreaModel]) {
        let alertController = UIAlertController(title: "Select Area", message: nil, preferredStyle: .actionSheet)
        
        for area in areas {
            let action = UIAlertAction(title: area.areaName, style: .default) { [weak self] _ in
                self?.selectedArea = area
            }
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = selectLocationButton
            popoverController.sourceRect = selectLocationButton.bounds
        }
        
        present(alertController, animated: true)
    }
    
    private func validateFields() -> Bool {
        var isValid = true
        
        if selectedViolation == nil {
            showAlert(title: "Error", message: "Please select a violation")
            isValid = false
        }
        
        if plateNumberField.textField.text?.isEmpty ?? true {
            plateNumberField.showError(true)
            isValid = false
        }
        
        if selectedArea == nil {
            showAlert(title: "Error", message: "Please select a location")
            isValid = false
        }
        
        return isValid
    }

    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Success",
            message: "Compound created successfully",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        })
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - ViolationSelectionDelegate
extension AddCompoundViewController: ViolationSelectionDelegate {
    func didSelectViolation(_ violation: ViolationData) {
        selectedViolation = violation
        selectedViolationLabel.text = "\(violation.violationCode) - \(violation.description)"
    }
}

// MARK: - Date Extension
extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
}

extension AddCompoundViewController: ParkingManagerDelegate {
    func didFetchAreaData(_ areasModel: [AreaModel]) {
        DispatchQueue.main.async { [weak self] in
            self?.showAreaSelectionMenu(areasModel)
        }
    }
}

extension AddCompoundViewController: CompoundManagerDelegate{
    func didCreateCompound() {
        DispatchQueue.main.async {
            self.showSuccessAlert()
        }
    }
    
    func didFailCreateCompound(_ error: any Error) {
        DispatchQueue.main.async {
            self.showAlert(title: "Error", message: "\(error)")
        }
    }
}

extension AddCompoundViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
