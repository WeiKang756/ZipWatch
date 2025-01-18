
// MARK: - ParkingSpotCell
class ParkingSpotCell: UITableViewCell {
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
    
    private let spotIdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if animated {
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
                self.containerView.backgroundColor = highlighted ? .systemGray6 : .white
            }
        } else {
            containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            containerView.backgroundColor = highlighted ? .systemGray6 : .white
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if animated {
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = selected ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
                self.containerView.backgroundColor = selected ? .systemGray6 : .white
            }
        } else {
            containerView.transform = selected ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            containerView.backgroundColor = selected ? .systemGray6 : .white
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(spotIdLabel)
        containerView.addSubview(typeLabel)
        containerView.addSubview(statusContainer)
        statusContainer.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            spotIdLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            spotIdLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            typeLabel.topAnchor.constraint(equalTo: spotIdLabel.bottomAnchor, constant: 4),
            typeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            statusContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            statusContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            statusContainer.heightAnchor.constraint(equalToConstant: 28),
            
            statusLabel.topAnchor.constraint(equalTo: statusContainer.topAnchor, constant: 6),
            statusLabel.bottomAnchor.constraint(equalTo: statusContainer.bottomAnchor, constant: -6),
            statusLabel.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor, constant: -12)
        ])
    }
    
    func configure(with spot: ParkingSpotModel) {
        spotIdLabel.text = "Spot #\(spot.parkingSpotID)"
        typeLabel.text = "Type: \(spot.type.capitalized)"
        
        statusLabel.text = spot.isAvailable ? "AVAILABLE" : "OCCUPIED"
        
        // Configure status style based on availability
        if spot.isAvailable {
            statusContainer.backgroundColor = .systemGreen.withAlphaComponent(0.1)
            statusLabel.textColor = .systemGreen
        } else {
            statusContainer.backgroundColor = .systemRed.withAlphaComponent(0.1)
            statusLabel.textColor = .systemRed
        }
        
        // Configure container style based on type
        switch spot.type.lowercased() {
        case "green":
            containerView.layer.borderColor = UIColor.systemGreen.cgColor
            typeLabel.textColor = .systemGreen
        case "yellow":
            containerView.layer.borderColor = UIColor.systemYellow.cgColor
            typeLabel.textColor = .systemYellow
        case "red":
            containerView.layer.borderColor = UIColor.systemRed.cgColor
            typeLabel.textColor = .systemRed
        case "disable":
            containerView.layer.borderColor = UIColor.systemBlue.cgColor
            typeLabel.textColor = .systemBlue
        default:
            containerView.layer.borderColor = UIColor.clear.cgColor
            typeLabel.textColor = .secondaryLabel
        }
        containerView.layer.borderWidth = 1
    }
}
