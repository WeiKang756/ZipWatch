class AddCompoundViewController: UIViewController {
    // MARK: - Properties
    private let supabase = SupabaseManager.shared.client
    private var selectedViolation: ViolationData?
    
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "New Compound"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let violationSelectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let violationLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Violation"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectedViolationLabel: UILabel = {
        let label = UILabel()
        label.text = "No violation selected"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectViolationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select", for: .normal)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let parkingSpotField = FormFieldView(title: "PARKING SPOT ID", placeholder: "Enter parking spot ID")
    private let dueDateField = FormFieldView(title: "DUE DATE", placeholder: "Select due date")
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Compound", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Date picker for due date
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.minimumDate = Date()
        return picker
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
        title = "New Compound"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(titleLabel)
        
        contentView.addSubview(violationSelectionView)
        violationSelectionView.addSubview(violationLabel)
        violationSelectionView.addSubview(selectedViolationLabel)
        violationSelectionView.addSubview(selectViolationButton)
        
        contentView.addSubview(parkingSpotField)
        contentView.addSubview(dueDateField)
        contentView.addSubview(createButton)
        
        // Setup date picker toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(datePickerDone))
        toolbar.setItems([doneButton], animated: true)
        dueDateField.textField.inputAccessoryView = toolbar
        dueDateField.textField.inputView = datePicker
        
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
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            
            violationSelectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            violationSelectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            violationSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            violationLabel.topAnchor.constraint(equalTo: violationSelectionView.topAnchor, constant: 16),
            violationLabel.leadingAnchor.constraint(equalTo: violationSelectionView.leadingAnchor, constant: 16),
            
            selectedViolationLabel.topAnchor.constraint(equalTo: violationLabel.bottomAnchor, constant: 8),
            selectedViolationLabel.leadingAnchor.constraint(equalTo: violationSelectionView.leadingAnchor, constant: 16),
            selectedViolationLabel.trailingAnchor.constraint(equalTo: selectViolationButton.leadingAnchor, constant: -16),
            selectedViolationLabel.bottomAnchor.constraint(equalTo: violationSelectionView.bottomAnchor, constant: -16),
            
            selectViolationButton.centerYAnchor.constraint(equalTo: selectedViolationLabel.centerYAnchor),
            selectViolationButton.trailingAnchor.constraint(equalTo: violationSelectionView.trailingAnchor, constant: -16),
            selectViolationButton.widthAnchor.constraint(equalToConstant: 80),
            
            parkingSpotField.topAnchor.constraint(equalTo: violationSelectionView.bottomAnchor, constant: 24),
            parkingSpotField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            parkingSpotField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dueDateField.topAnchor.constraint(equalTo: parkingSpotField.bottomAnchor, constant: 16),
            dueDateField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dueDateField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            createButton.topAnchor.constraint(equalTo: dueDateField.bottomAnchor, constant: 32),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 50),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupActions() {
        selectViolationButton.addTarget(self, action: #selector(selectViolationTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    @objc private func selectV