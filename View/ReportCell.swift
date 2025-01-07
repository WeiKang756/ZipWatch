//
//  ReportCell.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 04/01/2025.
//
import UIKit

// MARK: - ReportCell
class ReportCell: UITableViewCell {
    private let containerView: UIView = {
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
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let reportIdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
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
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(typeLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(locationLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(statusContainer)
        statusContainer.addSubview(statusLabel)

        containerView.addSubview(reportIdLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            typeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            typeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            reportIdLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 4),
            reportIdLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            descriptionLabel.topAnchor.constraint(equalTo: reportIdLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            locationLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            dateLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            statusContainer.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor),
            statusContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            statusContainer.heightAnchor.constraint(equalToConstant: 24),
            statusContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            statusLabel.centerXAnchor.constraint(equalTo: statusContainer.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: statusContainer.centerYAnchor)
        ])
    }
    
    func configure(with report: ReportData) {
        typeLabel.text = report.issueType
        descriptionLabel.text = report.description
        locationLabel.text = "Spot #\(report.parkingSpotID)"
        
        if let reportId = report.id?.uuidString {
            reportIdLabel.text = "Report #" + String(reportId.prefix(8))  // Show first 8 characters of UUID
        }
        
        if let date = report.date {
            dateLabel.text = DateFormatterUtility.shared.formatDate(date, to: .dateTime)
        }
        
        switch report.status {
            case "pending":
                statusContainer.backgroundColor = .systemOrange.withAlphaComponent(0.2)
                statusLabel.textColor = .systemOrange
            case "in progress":
                statusContainer.backgroundColor = .systemBlue.withAlphaComponent(0.2)
                statusLabel.textColor = .systemBlue
            case "resolved":
                statusContainer.backgroundColor = .systemGreen.withAlphaComponent(0.2)
                statusLabel.textColor = .systemGreen
            default:
                statusContainer.backgroundColor = .systemGray.withAlphaComponent(0.2)
                statusLabel.textColor = .systemGray
        }
        statusLabel.text = report.status.uppercased()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        UIView.animate(withDuration: 0.2) {
            self.containerView.transform = selected ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.containerView.backgroundColor = selected ? .systemGray6 : .white
        }
    }
}

