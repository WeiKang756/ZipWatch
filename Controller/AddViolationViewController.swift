//
//  AddViolationViewController.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 16/01/2025.
//
import UIKit

class AddViolationViewController: UIViewController {
    // MARK: - Properties
    private let supabase = SupabaseManager.shared.client
    
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
        label.text = "Add New Violation"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter violation details below"
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
    
    private let codeField = FormFieldView(title: "VIOLATION CODE", placeholder: "Enter code (e.g., MO-001)")
    private let sectionField = FormFieldView(title: "SECTION", placeholder: "Enter section (e.g., 8(1))")
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 17)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "DESCRIPTION"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let baseAmountField = FormFieldView(title: "BASE AMOUNT (RM)", placeholder: "Enter base amount")
    private let amount7DaysField = FormFieldView(title: "7 DAYS AMOUNT (RM)", placeholder: "Enter 7 days amount")
    private let amount30DaysField = FormFieldView(title: "30 DAYS AMOUNT (RM)", placeholder: "Enter 30 days amount")
    private let amount60DaysField = FormFieldView(title: "60 DAYS AMOUNT (RM)", placeholder: "Enter 60 days amount")
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Violation", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemRed
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
        formCard.addSubview(codeField)
        formCard.addSubview(sectionField)
        formCard.addSubview(descriptionTitleLabel)
        formCard.addSubview(descriptionTextView)
        formCard.addSubview(baseAmountField)
        formCard.addSubview(amount7DaysField)
        formCard.addSubview(amount30DaysField)
        formCard.addSubview(amount60DaysField)
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
            
            codeField.topAnchor.constraint(equalTo: formCard.topAnchor, constant: 20),
            codeField.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            codeField.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -20),
            
            sectionField.topAnchor.constraint(equalTo: codeField.bottomAnchor, constant: 16),
            sectionField.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            sectionField.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -20),
            
            descriptionTitleLabel.topAnchor.constraint(equalTo: sectionField.bottomAnchor, constant: 16),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 8),
            descriptionTextView.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            baseAmountField.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 16),
            baseAmountField.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            baseAmountField.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -20),
            
            amount7DaysField.topAnchor.constraint(equalTo: baseAmountField.bottomAnchor, constant: 16),
            amount7DaysField.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            amount7DaysField.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -20),
            
            amount30DaysField.topAnchor.constraint(equalTo: amount7DaysField.bottomAnchor, constant: 16),
            amount30DaysField.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            amount30DaysField.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -20),
            
            amount60DaysField.topAnchor.constraint(equalTo: amount30DaysField.bottomAnchor, constant: 16),
            amount60DaysField.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            amount60DaysField.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -20),
            
            addButton.topAnchor.constraint(equalTo: amount60DaysField.bottomAnchor, constant: 24),
            addButton.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            addButton.bottomAnchor.constraint(equalTo: formCard.bottomAnchor, constant: -20)
        ])
        
        setupKeyboardHandling()
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    private func setupKeyboardHandling() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        guard validateFields() else { return }
        
        guard let violationCode = codeField.textField.text,
              let section = sectionField.textField.text,
              let description = descriptionTextView.text,
              let baseAmountText = baseAmountField.textField.text,
              let amount7DaysText = amount7DaysField.textField.text,
              let amount30DaysText = amount30DaysField.textField.text,
              let amount60DaysText = amount60DaysField.textField.text,
              let baseAmount = Double(baseAmountText),
              let amount7Days = Double(amount7DaysText),
              let amount30Days = Double(amount30DaysText),
              let amount60Days = Double(amount60DaysText) else {
            showAlert(title: "Error", message: "Please enter valid values")
            return
        }
        
        let violation = ViolationRequest(
            violationCode: violationCode,
            section: section,
            description: description,
            baseAmount: baseAmount,
            amount7Days: amount7Days,
            amount30Days: amount30Days,
            amount60Days: amount60Days
        )
        
        Task {
            do {
                try await supabase
                    .from("violations")
                    .insert(violation)
                    .execute()
                
                DispatchQueue.main.async { [weak self] in
                    self?.showSuccessAlert()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
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
    
    // MARK: - Validation
    private func validateFields() -> Bool {
        // Reset error states
        [codeField, sectionField, baseAmountField, amount7DaysField, amount30DaysField, amount60DaysField].forEach {
            $0.hideError()
        }
        
        var isValid = true
        
        // Validate required fields
        if codeField.textField.text?.isEmpty ?? true {
            codeField.showError(true)
            isValid = false
        }
        
        if sectionField.textField.text?.isEmpty ?? true {
            sectionField.showError(true)
            isValid = false
        }
        
        if descriptionTextView.text.isEmpty {
            descriptionTextView.layer.borderColor = UIColor.systemRed.cgColor
            isValid = false
        }
        
        // Validate amounts
        let amountFields = [baseAmountField, amount7DaysField, amount30DaysField, amount60DaysField]
        for field in amountFields {
            if let text = field.textField.text, !text.isEmpty {
                if Double(text) == nil {
                    field.showError(true)
                    isValid = false
                }
            } else {
                field.showError(true)
                isValid = false
            }
        }
        
        if !isValid {
            showAlert(title: "Error", message: "Please fill in all fields correctly")
        }
        
        return isValid
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Success",
            message: "Violation added successfully",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension AddViolationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
