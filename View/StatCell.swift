//
//  StatCell.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 03/01/2025.
//
import UIKit

// Stat Cell
class StatCell: UICollectionViewCell {
    static let identifier = "StatCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(changeLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            changeLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8),
            changeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
    
    func configure(with item: StatItem) {
        titleLabel.text = item.title
        valueLabel.text = item.value
        changeLabel.text = item.change
        changeLabel.textColor = item.isPositive ? .systemGreen : .systemRed
    }
}

