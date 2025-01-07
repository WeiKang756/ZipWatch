import UIKit

class LoginViewController: UIViewController {
    // MARK: - Properties
    private var loginManger = LoginManager()
    
    // MARK: - UI Components
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "shield.fill")
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome Back"
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in to continue"
        label.textColor = .white.withAlphaComponent(0.8)
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let formContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emailField: FormFieldView = {
        let field = FormFieldView(title: "Email", placeholder: "Enter your Email")
        field.textField.font = .systemFont(ofSize: 17, weight: .regular)
        field.textField.keyboardType = .asciiCapable
        field.textField.autocapitalizationType = .none
        field.textField.autocorrectionType = .no
        return field
    }()
    
    private let passwordField: FormFieldView = {
        let field = FormFieldView(title: "PASSWORD", placeholder: "Enter your password")
        field.textField.font = .systemFont(ofSize: 17, weight: .regular)
        field.textField.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
        setupActions()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(headerView)
        headerView.addSubview(headerImageView)
        headerView.addSubview(welcomeLabel)
        headerView.addSubview(subtitleLabel)
        
        view.addSubview(formContainer)
        formContainer.addSubview(emailField)
        formContainer.addSubview(passwordField)
        formContainer.addSubview(errorLabel)
        formContainer.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
            
            headerImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerImageView.widthAnchor.constraint(equalToConstant: 60),
            headerImageView.heightAnchor.constraint(equalToConstant: 60),
            
            welcomeLabel.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 16),
            welcomeLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
    
            // Form Container
            formContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            formContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            formContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            formContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emailField.topAnchor.constraint(equalTo: formContainer.topAnchor, constant: 40),
            emailField.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -20),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20),
            passwordField.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -20),
            
            errorLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -20),
            
            loginButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            loginButton.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupDelegates() {
        emailField.textField.delegate = self
        passwordField.textField.delegate = self
        loginManger.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func viewTapped() {
        view.endEditing(true)
    }
    
    @objc private func loginButtonTapped() {
        if validateFields() {
            // Perform login based on selected role
            attemptLogin()
        } else {
            shakeButton()
        }
    }
    
    private func validateFields() -> Bool {
        let isIdValid = !(emailField.textField.text?.isEmpty ?? true)
        let isPasswordValid = !(passwordField.textField.text?.isEmpty ?? true)
        
        emailField.showError(!isIdValid)
        passwordField.showError(!isPasswordValid)
        
        if !isIdValid || !isPasswordValid {
            errorLabel.text = "Please fill in all fields"
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }
        
        return isIdValid && isPasswordValid
    }
    
    private func shakeButton() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        loginButton.layer.add(animation, forKey: "shake")
    }
    
    private func attemptLogin() {
        guard let email = emailField.textField.text,
              let password = passwordField.textField.text else { return }
        
        loginManger.signIn(email: email, password: password)
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField.textField {
            passwordField.textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            loginButtonTapped()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailField.textField {
            emailField.hideError()
        } else if textField == passwordField.textField {
            passwordField.hideError()
        }
        errorLabel.isHidden = true
    }
}

extension LoginViewController: LoginManagerDelegate {
    func didSignIn(_ result: Bool, _ description: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if result {
                // Success handling
                let navigationController = UINavigationController(rootViewController: OfficialHomeViewController())
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = navigationController
                    window.makeKeyAndVisible()
                    
                    UIView.transition(with: window,
                                    duration: 0.5,
                                    options: [.transitionCrossDissolve],
                                    animations: nil,
                                    completion: nil)
                }
            } else {
                // Error handling
                self.errorLabel.text = description
                self.errorLabel.isHidden = false
                self.shakeButton()
                
                // Visual feedback for error
                self.emailField.textField.layer.borderColor = UIColor.systemRed.cgColor
                self.passwordField.textField.layer.borderColor = UIColor.systemRed.cgColor
                
                // Clear password field for security
                self.passwordField.textField.text = ""
            }
        }
    }
}
