import UIKit

class AddAreaViewController: UIViewController {
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
    
    private let areaNameField: FormFieldView = {
        let field = FormFieldView(title: "Area Name", placeholder: "Enter area name")
        field.titleLabel.textColor = .black
        return field
    }()
    
    private let latitudeField: FormFieldView = {
        let field = FormFieldView(title: "Latitude", placeholder: "Enter latitude")
        field.textField.keyboardType = .decimalPad
        field.titleLabel.textColor = .black
        return field
    }()
    
    private let longitudeField: FormFieldView = {
        let field = FormFieldView(title: "Longitude", placeholder: "Enter longitude")
        field.textField.keyboardType = .decimalPad
        field.titleLabel.textColor = .black
        return field
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Area", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var addParkingManager = AddParkingManager()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        addParkingManager.delegate = self
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(areaNameField)
        contentView.addSubview(latitudeField)
        contentView.addSubview(longitudeField)
        contentView.addSubview(addButton)
        
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
            
            areaNameField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            areaNameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            areaNameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            latitudeField.topAnchor.constraint(equalTo: areaNameField.bottomAnchor, constant: 20),
            latitudeField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            latitudeField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            longitudeField.topAnchor.constraint(equalTo: latitudeField.bottomAnchor, constant: 20),
            longitudeField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            longitudeField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            addButton.topAnchor.constraint(equalTo: longitudeField.bottomAnchor, constant: 24),
            addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        setupKeyboardHandling()
    }
    
    private func setupNavigationBar() {
        title = "Add Area"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    private func setupKeyboardHandling() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        guard validateFields() else { return }
        guard let areaName = areaNameField.textField.text,
              let latitudeText = latitudeField.textField.text,
              let longitudeText = longitudeField.textField.text,
              let latitude = Double(latitudeText),
              let longitude = Double(longitudeText) else {
            showAlert(message: "Invalid input values")
            return
        }
        
        let area = AreaInsertData(areaName: areaName, latitude: latitude, longitude: longitude)
        addParkingManager.addArea(area: area)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    // MARK: - Helpers
    private func validateFields() -> Bool {
        var isValid = true
        
        if areaNameField.textField.text?.isEmpty ?? true {
            areaNameField.showError(true)
            isValid = false
        }
        
        if latitudeField.textField.text?.isEmpty ?? true {
            latitudeField.showError(true)
            isValid = false
        }
        
        if longitudeField.textField.text?.isEmpty ?? true {
            longitudeField.showError(true)
            isValid = false
        }
        
        return isValid
    }
    
    private func showSuccess() {
        let alert = UIAlertController(
            title: "Success",
            message: "Area added successfully",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AddAreaViewController: AddParkingManagerDelegate{
    func didFailAddArea() {
        DispatchQueue.main.async {
            self.showAlert(message: "Fail to add Area. Please find technical support")
        }
    }
    
    func didAddArea() {
        DispatchQueue.main.async {
            self.showSuccess()
        }
    }
    
}

#Preview {
    AddAreaViewController()
}
