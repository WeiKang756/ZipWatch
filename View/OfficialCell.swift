//
//  OfficialCell.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 06/01/2025.
//
import UIKit

// MARK: - Official Cell
class OfficialCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let idLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let roleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
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
        selectionStyle = .none
        contentView.addSubview(containerView)
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(idLabel)
        containerView.addSubview(roleLabel)
        containerView.addSubview(emailLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            idLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            idLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            roleLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 4),
            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            roleLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            emailLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with cityOfficial: Official) {
        nameLabel.text = cityOfficial.name
        idLabel.text = "ID: \(cityOfficial.officialId)"
        roleLabel.text = "Role: \(cityOfficial.type)"
        emailLabel.text = "Email: \(cityOfficial.createdAt)"
    }
}
