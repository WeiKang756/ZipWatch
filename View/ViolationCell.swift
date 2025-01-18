//
//  ViolationCell.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 16/01/2025.
//
import UIKit

class ViolationCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let codeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sectionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(codeLabel)
        containerView.addSubview(sectionLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(amountsStackView)
        
        // Create amount views
        let amounts = ["7 Days", "30 Days", "60 Days"]
        amounts.forEach { title in
            let amountView = createAmountView(title: title)
            amountsStackView.addArrangedSubview(amountView)
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            codeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            codeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            sectionLabel.centerYAnchor.constraint(equalTo: codeLabel.centerYAnchor),
            sectionLabel.leadingAnchor.constraint(equalTo: codeLabel.trailingAnchor, constant: 8),
            
            descriptionLabel.topAnchor.constraint(equalTo: codeLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            amountsStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            amountsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            amountsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            amountsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            amountsStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createAmountView(title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 8
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = .secondaryLabel
        
        let amountLabel = UILabel()
        amountLabel.font = .systemFont(ofSize: 14, weight: .medium)
        amountLabel.tag = title.hashValue
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(amountLabel)
        
        container.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    func configure(with violation: ViolationData) {
        codeLabel.text = violation.violationCode
        sectionLabel.text = "Section \(violation.section)"
        descriptionLabel.text = violation.description
        
        if let sevenDaysLabel = amountsStackView.arrangedSubviews[0].viewWithTag("7 Days".hashValue) as? UILabel {
            sevenDaysLabel.text = String(format: "RM %.2f", violation.amount7Days)
        }
        
        if let thirtyDaysLabel = amountsStackView.arrangedSubviews[1].viewWithTag("30 Days".hashValue) as? UILabel {
            thirtyDaysLabel.text = String(format: "RM %.2f", violation.amount30Days)
        }
        
        if let sixtyDaysLabel = amountsStackView.arrangedSubviews[2].viewWithTag("60 Days".hashValue) as? UILabel {
            sixtyDaysLabel.text = String(format: "RM %.2f", violation.amount60Days)
        }
    }
}
