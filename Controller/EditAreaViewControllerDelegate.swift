//
//  EditAreaViewControllerDelegate.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 16/01/2025.
//
import UIKit

protocol EditAreaViewControllerDelegate: AnyObject {
    func didUpdateArea()
}

class EditAreaViewController: UIViewController{
    // MARK: - Properties
    private let area: AreaModel
    private let supabase = SupabaseManager.shared.client
    weak var delegate: EditAreaViewControllerDelegate?
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
    
    private let nameField = FormFieldView(title: "AREA NAME", placeholder: "Enter area name")
    private let latitudeField = FormFieldView(title: "LATITUDE", placeholder: "Enter latitude")
    private let longitudeField = FormFieldView(title: "LONGITUDE", placeholder: "Enter longitude")
    
    private let updateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update Area", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    init(area: AreaModel) {
        self.area = area
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithArea()
        setupKeyboardHandling()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Edit Area"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(nameField)
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
            
            nameField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            latitudeField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 20),
            latitudeField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            latitudeField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            longitudeField.topAnchor.constraint(equalTo: latitudeField.bottomAnchor, constant: 20),
            longitudeField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            longitudeField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            updateButton.topAnchor.constraint(equalTo: longitudeField.bottomAnchor, constant: 30),
            updateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            updateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            updateButton.heightAnchor.constraint(equalToConstant: 50),
            updateButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
    }
    
    private func configureWithArea() {
        nameField.textField.text = area.areaName
        latitudeField.textField.text = String(area.latitude)
        longitudeField.textField.text = String(area.longtitude)
    }
    
    @objc private func updateButtonTapped() {
        guard let name = nameField.textField.text, !name.isEmpty,
              let latitudeText = latitudeField.textField.text,
              let longitudeText = longitudeField.textField.text,
              let latitude = Double(latitudeText),
              let longitude = Double(longitudeText) else {
            showAlert(title: "Error", message: "Please fill all fields with valid values")
            return
        }
        
        Task {
            let areaInsertData = AreaInsertData(areaName: name, latitude: latitude, longitude: longitude)
            do {
                try await supabase
                    .from("Area")
                    .update(areaInsertData)
                    .eq("areaID", value: area.areaID)
                    .execute()
                
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didUpdateArea()
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
            message: "Area updated successfully",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func setupKeyboardHandling() {
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Register for keyboard notifications
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
        
        // Set delegates for textFields
        [nameField, latitudeField, longitudeField].forEach {
            $0.textField.delegate = self
        }
    }

    // Add these methods to handle keyboard
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let activeField = activeTextField else { return }
        
        let bottomOfTextField = activeField.convert(activeField.bounds, to: scrollView).maxY
        let topOfKeyboard = scrollView.frame.height - keyboardSize.height
        
        // Calculate the distance between the bottom of text field and top of keyboard
        let distanceToScroll = bottomOfTextField - topOfKeyboard + 20 // Add some padding
        
        if distanceToScroll > 0 {
            scrollView.setContentOffset(CGPoint(x: 0, y: distanceToScroll), animated: true)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.setContentOffset(.zero, animated: true)
    }

    // Add deinit to remove observers
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension EditAreaViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField.textField:
            latitudeField.textField.becomeFirstResponder()
        case latitudeField.textField:
            longitudeField.textField.becomeFirstResponder()
        case longitudeField.textField:
            textField.resignFirstResponder()
            updateButtonTapped()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
