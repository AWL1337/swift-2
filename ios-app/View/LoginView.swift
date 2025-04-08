import UIKit

class LoginView: UIViewController {
    private let viewModel: LoginViewModel
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.layer.borderWidth = 1.0
        tf.layer.cornerRadius = 5.0
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.layer.borderWidth = 1.0
        tf.layer.cornerRadius = 5.0
        return tf
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Login", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.isEnabled = false
        btn.alpha = 0.5
        return btn
    }()
    
    private let errorLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .red
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.font = .systemFont(ofSize: 14)
        lbl.isHidden = true
        return lbl
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        setupActions()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Login"
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
           
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    
    private func bindViewModel() {
        emailTextField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        
        viewModel.isEmailValid.bind { [weak self] isValid in
            self?.emailTextField.layer.borderColor = isValid ? UIColor.green.cgColor : UIColor.red.cgColor
            self?.updateLoginButtonState()
        }
        
        viewModel.isPasswordValid.bind { [weak self] isValid in
            self?.passwordTextField.layer.borderColor = isValid ? UIColor.green.cgColor : UIColor.red.cgColor
            self?.updateLoginButtonState()
        }
        
        viewModel.errorMessage.bind { [weak self] message in
            self?.errorLabel.text = message
            self?.errorLabel.isHidden = message == nil
            if message != nil {
                UIView.animate(withDuration: 0.3) {
                    self?.errorLabel.alpha = 1.0
                }
            }
        }
        
        viewModel.isLoading.bind { [weak self] isLoading in
            self?.loginButton.isEnabled = !isLoading
            self?.loginButton.setTitle(isLoading ? "Loading..." : "Login", for: .normal)
            self?.loginButton.alpha = isLoading ? 0.5 : 1.0
        }
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }
    
    @objc private func emailChanged() {
        viewModel.email = emailTextField.text ?? ""
    }
    
    @objc private func passwordChanged() {
        viewModel.password = passwordTextField.text ?? ""
    }
    
    @objc private func loginTapped() {
        viewModel.login { [weak self] success in
            if success {
                print("Login successful")
            }
        }
    }
    
    private func updateLoginButtonState() {
        let isFormValid = viewModel.isEmailValid.value && viewModel.isPasswordValid.value
        loginButton.isEnabled = isFormValid && !viewModel.isLoading.value
        loginButton.alpha = loginButton.isEnabled ? 1.0 : 0.5
    }
}
