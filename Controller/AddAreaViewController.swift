import UIKit
import CoreLocation

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
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Add New Area"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    private let currentLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Use Current Location", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Area", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let locationManager = CLLocationManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Add Area"
        
        view.addSubview(headerView)
        headerView.addSubview(headerLabel)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(areaNameField)
        contentView.addSubview(latitudeField)
        contentView.addSubview(longitudeField)
        contentView.addSubview(currentLocationButton)
        contentView.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Form Fields
            areaNameField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            areaNameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            areaNameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            latitudeField.topAnchor.constraint(equalTo: areaNameField.bottomAnchor, constant: 20),
            latitudeField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            latitudeField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            longitudeField.topAnchor.constraint(equalTo: latitudeField.bottomAnchor, constant: 20),
            longitudeField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            longitudeField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            currentLocationButton.topAnchor.constraint(equalTo: longitudeField.bottomAnchor, constant: 24),
            currentLocationButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            currentLocationButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            currentLocationButton.heightAnchor.constraint(equalToConstant: 50),
            
            addButton.topAnchor.constraint(equalTo: currentLocationButton.bottomAnchor, constant: 16),
            addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        setupKeyboardHandling()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func setupActions() {
        currentLocationButton.addTarget(self, action: #selector(currentLocationTapped), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    private func setupKeyboardHandling() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Actions
    @objc private func currentLocationTapped() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            showLocationServicesAlert()
        }
    }
    
    @objc private func addButtonTapped() {
        guard validateFields() else { return }
        // Handle add area action
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
    
    private func showLocationServicesAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services in Settings to use this feature.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate
extension AddAreaViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            latitudeField.textField.text = String(format: "%.6f", location.coordinate.latitude)
            longitudeField.textField.text = String(format: "%.6f", location.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error)
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to get location",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}