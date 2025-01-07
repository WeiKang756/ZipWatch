//
//  EditOfficialViewController.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 06/01/2025.
//
import UIKit

protocol OfficialListViewControllerDelegate: AnyObject {
    func didUpdateOfficial()
}

extension OfficialListViewController: OfficialListViewControllerDelegate {
    func didUpdateOfficial() {
        officialManager.fetchCityOfficials()
        officialManager.fetchEnforcementOfficials()
    }
}

class EditOfficialViewController: UIViewController {
    // MARK: - Properties
    private let official: Official
    private let supabase = SupabaseManager.shared.client
    weak var delegate: OfficialListViewControllerDelegate?
    
    // MARK: - UI Components
    private let nameTextField = CustomTextField(placeholder: "Full Name")
    private let roleSegmentControl: UISegmentedControl = {
        let items = ["City Official", "Enforcement Official"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentTintColor = .black
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Changes", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    init(official: Official) {
        self.official = official
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithOfficial()
        setupKeyboardHandling()
    }
    
    // MARK: - Setup
    private func setupKeyboardHandling() {
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Add keyboard notifications
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        // Make text field delegate
        nameTextField.delegate = self
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        
        // Adjust content inset and scroll indicator insets
        if let scrollView = view as? UIScrollView {
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        // Reset content inset and scroll indicator insets
        if let scrollView = view as? UIScrollView {
            scrollView.contentInset = .zero
            scrollView.scrollIndicatorInsets = .zero
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Edit Official"
        
        view.addSubview(nameTextField)
        view.addSubview(roleSegmentControl)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            roleSegmentControl.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            roleSegmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            roleSegmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    private func configureWithOfficial() {
        nameTextField.text = official.name
        roleSegmentControl.selectedSegmentIndex = official.type == "city_official" ? 0 : 1
    }
    
    // MARK: - Actions
    @objc private func saveButtonTapped() {
        guard let newName = nameTextField.text, !newName.isEmpty else {
            showAlert(message: "Please enter a name")
            return
        }
        
        let newType = roleSegmentControl.selectedSegmentIndex == 0 ? "city_official" : "enforcement_official"
        
        Task {
            do {
                try await supabase
                    .from("officials")
                    .update([
                        "name": newName,
                        "type": newType
                    ])
                    .eq("id", value: official.id)
                    .execute()
                
                DispatchQueue.main.async {
                    self.delegate?.didUpdateOfficial()
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(message: "Failed to update official: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension EditOfficialViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
