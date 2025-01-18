//
//  StreetCell.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 16/01/2025.
//
import UIKit

// MARK: - StreetCell
class StreetCell: UITableViewCell {
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
    
    private let streetNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let availabilityContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen.withAlphaComponent(0.1)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let availabilityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let parkingTypesStackView: UIStackView = {
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
        containerView.addSubview(streetNameLabel)
        containerView.addSubview(availabilityContainer)
        availabilityContainer.addSubview(availabilityLabel)
        containerView.addSubview(parkingTypesStackView)
        
        // Add parking type views
        let types = [("Green", UIColor.systemGreen), ("Yellow", UIColor.systemYellow),
                    ("Red", UIColor.systemRed), ("Disable", UIColor.systemBlue)]
        
        types.forEach { type, color in
            parkingTypesStackView.addArrangedSubview(createParkingTypeView(type: type, color: color))
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            streetNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            streetNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            availabilityContainer.centerYAnchor.constraint(equalTo: streetNameLabel.centerYAnchor),
            availabilityContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            availabilityContainer.heightAnchor.constraint(equalToConstant: 28),
            
            availabilityLabel.topAnchor.constraint(equalTo: availabilityContainer.topAnchor, constant: 6),
            availabilityLabel.bottomAnchor.constraint(equalTo: availabilityContainer.bottomAnchor, constant: -6),
            availabilityLabel.leadingAnchor.constraint(equalTo: availabilityContainer.leadingAnchor, constant: 12),
            availabilityLabel.trailingAnchor.constraint(equalTo: availabilityContainer.trailingAnchor, constant: -12),
            
            parkingTypesStackView.topAnchor.constraint(equalTo: streetNameLabel.bottomAnchor, constant: 16),
            parkingTypesStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            parkingTypesStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            parkingTypesStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            parkingTypesStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func createParkingTypeView(type: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.1)
        container.layer.cornerRadius = 8
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let typeLabel = UILabel()
        typeLabel.text = type
        typeLabel.font = .systemFont(ofSize: 12)
        typeLabel.textColor = color
        
        let countLabel = UILabel()
        countLabel.font = .systemFont(ofSize: 16, weight: .medium)
        countLabel.textColor = color
        countLabel.tag = type.hashValue
        
        stackView.addArrangedSubview(typeLabel)
        stackView.addArrangedSubview(countLabel)
        
        container.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    func configure(with street: StreetModel) {
        streetNameLabel.text = street.streetName
        availabilityLabel.text = "\(street.numAvailable) Available"
        
        // Update parking type counts
        if let greenLabel = parkingTypesStackView.arrangedSubviews[0].viewWithTag("Green".hashValue) as? UILabel {
            greenLabel.text = "\(street.numGreen)"
        }
        if let yellowLabel = parkingTypesStackView.arrangedSubviews[1].viewWithTag("Yellow".hashValue) as? UILabel {
            yellowLabel.text = "\(street.numYellow)"
        }
        if let redLabel = parkingTypesStackView.arrangedSubviews[2].viewWithTag("Red".hashValue) as? UILabel {
            redLabel.text = "\(street.numRed)"
        }
        if let disableLabel = parkingTypesStackView.arrangedSubviews[3].viewWithTag("Disable".hashValue) as? UILabel {
            disableLabel.text = "\(street.numDisable)"
        }
        
        // Update availability container color based on available spots
        let percentage = Double(street.numAvailable) / Double(street.parkingSpots.count) * 100
        if percentage >= 50 {
            availabilityContainer.backgroundColor = .systemGreen.withAlphaComponent(0.1)
            availabilityLabel.textColor = .systemGreen
        } else if percentage >= 20 {
            availabilityContainer.backgroundColor = .systemYellow.withAlphaComponent(0.1)
            availabilityLabel.textColor = .systemYellow
        } else {
            availabilityContainer.backgroundColor = .systemRed.withAlphaComponent(0.1)
            availabilityLabel.textColor = .systemRed
        }
    }
}
