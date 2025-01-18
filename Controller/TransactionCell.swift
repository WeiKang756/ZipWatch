//
//  TransactionCell.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 14/01/2025.
//

import UIKit

class TransactionCell: UITableViewCell {
    // MARK: - UI Components
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
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let referenceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(containerView)
        
        containerView.addSubview(typeLabel)
        containerView.addSubview(referenceLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            typeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            typeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            referenceLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 4),
            referenceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            amountLabel.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: referenceLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with transaction: TransactionListData) {
        typeLabel.text = transaction.transactionType.name
        referenceLabel.text = "Ref: \(transaction.referenceId)"
        amountLabel.text = String(format: "RM %.2f", transaction.amount)
        
        if let date = DateFormatterUtility.shared.dateFromString(transaction.transactionDate) {
            dateLabel.text = DateFormatterUtility.shared.formatDate(date, to: .dateTime)
        }
        
        switch transaction.typeId {
        case 1: // Top Up
            amountLabel.textColor = .systemGreen
            amountLabel.text = "+ " + (amountLabel.text ?? "")
        case 2, 3: // Parking Fees, Fines
            amountLabel.textColor = .systemRed
            amountLabel.text = "- " + (amountLabel.text ?? "")
        default:
            amountLabel.textColor = .label
        }
    }
}
