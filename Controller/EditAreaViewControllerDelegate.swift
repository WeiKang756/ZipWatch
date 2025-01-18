protocol EditAreaViewControllerDelegate: AnyObject {
    func didUpdateArea()
}

class EditAreaViewController: UIViewController {
    // MARK: - Properties
    private let area: AreaModel
    private let supabase = SupabaseManager.shared.client
    weak var delegate: EditAreaViewControllerDelegate?
    
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
    
    private let nameField = FormFieldView(title: "AREA NAME", placeholder: "Enter area name")
    private let latitudeField = FormFieldView(title: "LATITUDE", placeholder: "Enter latitude")
    private let longitudeField = FormFieldView(title: "LONGITUDE", placeholder: "Enter longitude")
    
    private let updateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update Area", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    init(area: AreaModel) {
        self.area = area
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithArea()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Edit Area"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(nameField)
        contentView.addSubview(latitudeField)
        contentView.addSubview(longitudeField)
        contentView.addSubview(updateButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            nameField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            latitudeField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 20),
            latitudeField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            latitudeField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            longitudeField.topAnchor.constraint(equalTo: latitudeField.bottomAnchor, constant: 20),
            longitudeField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            longitudeField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            updateButton.topAnchor.constraint(equalTo: longitudeField.bottomAnchor, constant: 30),
            updateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            updateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            updateButton.heightAnchor.constraint(equalToConstant: 50),
            updateButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
    }
    
    private func configureWithArea() {
        nameField.textField.text = area.areaName
        latitudeField.textField.text = String(area.latitude)
        longitudeField.textField.text = String(area.longtitude)
    }
    
    @objc private func updateButtonTapped() {
        guard let name = nameField.textField.text, !name.isEmpty,
              let latitudeText = latitudeField.textField.text,
              let longitudeText = longitudeField.textField.text,
              let latitude = Double(latitudeText),
              let longitude = Double(longitudeText) else {
            showAlert(title: "Error", message: "Please fill all fields with valid values")
            return
        }
        
        Task {
            do {
                try await supabase
                    .from("Area")
                    .update([
                        "areaName": name,
                        "latitude": latitude,
                        "longitude": longitude
                    ])
                    .eq("areaID", value: area.areaID)
                    .execute()
                
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didUpdateArea()
                    self?.showSuccessAlert()
                }
            } catch {
                showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Success",
            message: "Area updated successfully",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}