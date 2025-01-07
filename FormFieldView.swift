//
//  FormFieldView.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 28/11/2024.
//

import UIKit


class FormFieldView: UIView {
    // MARK: - UI Components
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let textField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.backgroundColor = .secondarySystemBackground
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemRed
        label.text = "This field is required"
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    init(title: String, placeholder: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        textField.placeholder = placeholder
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(textField)
        addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func showError(_ show: Bool) {
        errorLabel.isHidden = !show
        textField.layer.borderColor = show ? UIColor.systemRed.cgColor : nil
        textField.layer.borderWidth = show ? 1 : 0
    }
    
    func hideError() {
        showError(false)
    }
}
