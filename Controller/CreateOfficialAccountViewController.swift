//
//  CreateOfficialAccountViewController.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 05/01/2025.
//


import UIKit
import Supabase

class CreateOfficialAccountViewController: UIViewController {
    // MARK: - Properties
    private var selectedRole: OfficialRole = .cityOfficial
    private var accountManager = AccountManager()
    
    enum OfficialRole {
        case cityOfficial
        case enforcementOfficial
    }
    
    // MARK: - UI Components
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Official Account"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create accounts for city and enforcement officials"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemGray6
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    
    private let roleSegmentControl: UISegmentedControl = {
        let items = ["City Official", "Enforcement Official"]
        let segmentControl = UISegmentedControl(items: items)
        segmentControl.selectedSegmentIndex = 0
        segmentControl.backgroundColor = .systemGray6
        segmentControl.selectedSegmentTintColor = .black
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentControl
    }()
    
    // Text Fields
    private let nameTextField = CustomTextField(placeholder: "Full Name")
    private let emailTextField = CustomTextField(placeholder: "Email Address")
    private let officialIdTextField = CustomTextField(placeholder: "Official ID")
    private let passwordTextField = CustomTextField(placeholder: "Password", isSecure: true)
    private let confirmPasswordTextField = CustomTextField(placeholder: "Confirm Password", isSecure: true)
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Account", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupNavigationBar()
        accountManager.delegate = self
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupViews()
        setupConstraints()
        setupKeyboardHandling()
    }
    
    private func setupNavigationBar() {
        title = "Create Account"
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupViews() {
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(formCard)
        formCard.addSubview(roleSegmentControl)
        
        // Add text fields to form card
        formCard.addSubview(nameTextField)
        formCard.addSubview(emailTextField)
        formCard.addSubview(officialIdTextField)
        formCard.addSubview(passwordTextField)
        formCard.addSubview(confirmPasswordTextField)
        formCard.addSubview(createButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Form Card
            formCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            formCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            formCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            formCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            // Role Segment Control
            roleSegmentControl.topAnchor.constraint(equalTo: formCard.topAnchor, constant: 16),
            roleSegmentControl.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 16),
            roleSegmentControl.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -16),
            
            // Text Fields
            nameTextField.topAnchor.constraint(equalTo: roleSegmentControl.bottomAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -16),
            
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            emailTextField.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -16),
            
            officialIdTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            officialIdTextField.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 16),
            officialIdTextField.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -16),
            
            passwordTextField.topAnchor.constraint(equalTo: officialIdTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -16),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 16),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -16),
            
            // Create Button
            createButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 24),
            createButton.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 16),
            createButton.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -16),
            createButton.bottomAnchor.constraint(equalTo: formCard.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        roleSegmentControl.addTarget(self, action: #selector(roleChanged), for: .valueChanged)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    private func setupKeyboardHandling() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Actions
    @objc private func roleChanged(_ sender: UISegmentedControl) {
        selectedRole = sender.selectedSegmentIndex == 0 ? .cityOfficial : .enforcementOfficial
    }
    
    @objc private func createButtonTapped() {
        guard validateForm() else { return }
        createAccount()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    // MARK: - Validation & Account Creation
    private func validateForm() -> Bool {
        // Reset error states
        [nameTextField, emailTextField, officialIdTextField, passwordTextField, confirmPasswordTextField].forEach {
            $0.layer.borderWidth = 0
        }
        
        // Validate name
        guard let name = nameTextField.text, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError(for: nameTextField, message: "Please enter name")
            return false
        }
        
        // Validate email
        guard let email = emailTextField.text,
              !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              isValidEmail(email) else {
            showError(for: emailTextField, message: "Please enter a valid email address")
            return false
        }
        
        // Validate official ID
        guard let officialId = officialIdTextField.text, !officialId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError(for: officialIdTextField, message: "Please enter your official ID")
            return false
        }
        
        // Validate password
        guard let password = passwordTextField.text,
              password.count >= 8 else {
            showError(for: passwordTextField, message: "Password must be at least 8 characters")
            return false
        }
        
        // Validate password confirmation
        guard let confirmPassword = confirmPasswordTextField.text,
              confirmPassword == password else {
            showError(for: confirmPasswordTextField, message: "Passwords do not match")
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func showError(for textField: UITextField, message: String) {
        textField.layer.borderColor = UIColor.systemRed.cgColor
        textField.layer.borderWidth = 1
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
    private func createAccount() {
        var role: String
        switch selectedRole {
        case .cityOfficial:
            role = "city_official"
        case .enforcementOfficial:
            role = "enforcement_official"
        }
        
        let accountDetail = AccountDetail(name: nameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!, officialId: officialIdTextField.text!, role: role)
        
        accountManager.createAccount(accountDetail: accountDetail)
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Success",
            message: "Account created successfully",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


extension CreateOfficialAccountViewController: AccountManagerDelegate {
    func didCreateAccount(_ officialData: OfficialAccount) {
        self.showSuccessAlert()
    }
    
    func didFailCreateAccount(_ error: String) {
        DispatchQueue.main.async {
            self.showError(message: error)
        }
    }
    
    func didCreateAccount() {
        DispatchQueue.main.async {
            self.showSuccessAlert()
        }
    }
}
