import UIKit

class CompoundDetailViewController: UIViewController {
    // MARK: - Properties
    private let compound: CompoundData
    private let supabase = SupabaseManager.shared.client
    
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
    
    private let plateNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createdAtLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Compound Details Card
    private let compoundDetailsCard: UIView = {
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
    
    private let compoundStatusContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let compoundStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let paymentInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let paymentDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountPaidLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Violation Details Card
    private let violationCard: UIView = {
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
    
    private let violationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Violation Details"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let violationCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let violationDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialization
    init(compound: CompoundData) {
        self.compound = compound
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithCompound()
        fetchViolationDetails()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Compound Details"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(plateNumberLabel)
        headerView.addSubview(createdAtLabel)
        
        contentView.addSubview(compoundDetailsCard)
        compoundDetailsCard.addSubview(compoundStatusContainer)
        compoundStatusContainer.addSubview(compoundStatusLabel)
        compoundDetailsCard.addSubview(locationLabel)
        compoundDetailsCard.addSubview(paymentInfoView)
        paymentInfoView.addSubview(paymentDateLabel)
        paymentInfoView.addSubview(amountPaidLabel)
        
        contentView.addSubview(violationCard)
        violationCard.addSubview(violationTitleLabel)
        violationCard.addSubview(violationCodeLabel)
        violationCard.addSubview(violationDescriptionLabel)
        violationCard.addSubview(amountsStackView)
        
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
            
            plateNumberLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            plateNumberLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            createdAtLabel.topAnchor.constraint(equalTo: plateNumberLabel.bottomAnchor, constant: 8),
            createdAtLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            compoundDetailsCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            compoundDetailsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            compoundDetailsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            compoundStatusContainer.topAnchor.constraint(equalTo: compoundDetailsCard.topAnchor, constant: 20),
            compoundStatusContainer.leadingAnchor.constraint(equalTo: compoundDetailsCard.leadingAnchor, constant: 20),
            compoundStatusContainer.heightAnchor.constraint(equalToConstant: 24),
            
            compoundStatusLabel.topAnchor.constraint(equalTo: compoundStatusContainer.topAnchor, constant: 4),
            compoundStatusLabel.leadingAnchor.constraint(equalTo: compoundStatusContainer.leadingAnchor, constant: 12),
            compoundStatusLabel.trailingAnchor.constraint(equalTo: compoundStatusContainer.trailingAnchor, constant: -12),
            compoundStatusLabel.bottomAnchor.constraint(equalTo: compoundStatusContainer.bottomAnchor, constant: -4),
            
            locationLabel.topAnchor.constraint(equalTo: compoundStatusContainer.bottomAnchor, constant: 16),
            locationLabel.leadingAnchor.constraint(equalTo: compoundDetailsCard.leadingAnchor, constant: 20),
            locationLabel.trailingAnchor.constraint(equalTo: compoundDetailsCard.trailingAnchor, constant: -20),
            
            paymentInfoView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 16),
            paymentInfoView.leadingAnchor.constraint(equalTo: compoundDetailsCard.leadingAnchor, constant: 20),
            paymentInfoView.trailingAnchor.constraint(equalTo: compoundDetailsCard.trailingAnchor, constant: -20),
            paymentInfoView.bottomAnchor.constraint(equalTo: compoundDetailsCard.bottomAnchor, constant: -20),
            
            paymentDateLabel.topAnchor.constraint(equalTo: paymentInfoView.topAnchor, constant: 12),
            paymentDateLabel.leadingAnchor.constraint(equalTo: paymentInfoView.leadingAnchor, constant: 12),
            
            amountPaidLabel.topAnchor.constraint(equalTo: paymentDateLabel.bottomAnchor, constant: 8),
            amountPaidLabel.leadingAnchor.constraint(equalTo: paymentInfoView.leadingAnchor, constant: 12),
            amountPaidLabel.bottomAnchor.constraint(equalTo: paymentInfoView.bottomAnchor, constant: -12),
            
            violationCard.topAnchor.constraint(equalTo: compoundDetailsCard.bottomAnchor, constant: 20),
            violationCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            violationCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            violationCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            violationTitleLabel.topAnchor.constraint(equalTo: violationCard.topAnchor, constant: 20),
            violationTitleLabel.leadingAnchor.constraint(equalTo: violationCard.leadingAnchor, constant: 20),
            
            violationCodeLabel.topAnchor.constraint(equalTo: violationTitleLabel.bottomAnchor, constant: 16),
            violationCodeLabel.leadingAnchor.constraint(equalTo: violationCard.leadingAnchor, constant: 20),
            
            violationDescriptionLabel.topAnchor.constraint(equalTo: violationCodeLabel.bottomAnchor, constant: 8),
            violationDescriptionLabel.leadingAnchor.constraint(equalTo: violationCard.leadingAnchor, constant: 20),
            violationDescriptionLabel.trailingAnchor.constraint(equalTo: violationCard.trailingAnchor, constant: -20),
            
            amountsStackView.topAnchor.constraint(equalTo: violationDescriptionLabel.bottomAnchor, constant: 16),
            amountsStackView.leadingAnchor.constraint(equalTo: violationCard.leadingAnchor, constant: 20),
            amountsStackView.trailingAnchor.constraint(equalTo: violationCard.trailingAnchor, constant: -20),
            amountsStackView.bottomAnchor.constraint(equalTo: violationCard.bottomAnchor, constant: -20)
        ])
    }
    
    private func configureWithCompound() {
        plateNumberLabel.text = compound.plateNumber
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        createdAtLabel.text = "Created: \(dateFormatter.string(from: compound.createdAt))"
        locationLabel.text = compound.location
        
        // Configure status
        configureStatus()
        
        // Configure payment info
        if let paymentDate = compound.paymentDate {
            paymentDateLabel.text = "Paid on: \(dateFormatter.string(from: paymentDate))"
            if let amountPaid = compound.amountPaid {
                amountPaidLabel.text = String(format: "RM %.2f", amountPaid)
            }
            paymentInfoView.isHidden = false
        } else {
            paymentInfoView.isHidden = true
        }
    }
    
    private func configureStatus() {
        compoundStatusLabel.text = compound.status.uppercased()
        
        switch compound.status.lowercased() {
        case "pending":
            compoundStatusContainer.backgroundColor = .systemOrange.withAlphaComponent(0.2)
            compoundStatusLabel.textColor = .systemOrange
        case "paid":
            compoundStatusContainer.backgroundColor = .systemGreen.withAlphaComponent(0.2)
            compoundStatusLabel.textColor = .systemGreen
        case "overdue":
            compoundStatusContainer.backgroundColor = .systemRed.withAlphaComponent(0.2)
            compoundStatusLabel.textColor = .systemRed
        default:
            compoundStatusContainer.backgroundColor = .systemGray.withAlphaComponent(0.2)
            compoundStatusLabel.textColor = .systemGray
        }
    }
    
    private func fetchViolationDetails() {
        Task {
            do {
                let violation: ViolationData = try await supabase
                    .from("violations")
                    .select()
                    .eq("id", value: compound.violationId)
                    .single()
                    .execute()
                    .value
                
                DispatchQueue.main.async { [weak self] in
                    self?.configureViolationDetails(with: violation)
                }
            } catch {
                print("Error fetching violation details:", error)
                showAlert(message: "Failed to fetch violation details")
            }
        }
    }
    
    private func configureViolationDetails(with violation: ViolationData) {
        violationCodeLabel.text = "Code: \(violation.violationCode)"
        violationDescriptionLabel.text = violation.description
        
        // Clear existing amount views
        amountsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Configure amount labels
        let amounts = [
            ("7 Days", violation.amount7Days),
            ("30 Days", violation.amount30Days),
            ("60 Days", violation.amount60Days)
        ]
        
        amounts.forEach { title, amount in
            let amountView = createAmountView(title: title, amount: amount)
            amountsStackView.addArrangedSubview(amountView)
        }
    }
    
    private func createAmountView(title: String, amount: Double) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 8
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let amountLabel = UILabel()
        amountLabel.text = String(format: "RM %.2f", amount)
        amountLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(amountLabel)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            amountLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            amountLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}