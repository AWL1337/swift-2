import UIKit
import Combine

protocol LoginViewControllerDelegate: AnyObject {
    func didLoginSuccessfully()
}

protocol LoginViewControllerProtocol: AnyObject {
    var emailTextField: UITextField { get }
    var passwordTextField: UITextField { get }
    var loginButton: UIButton { get }
    var errorLabel: UILabel { get }
    var viewModel: LoginViewModel { get }
    
    func updateLoginButtonState()
    func emailChanged(_ text: String)
    func passwordChanged(_ text: String)
    func loginTapped(completion: @escaping (Bool) -> Void)
}

class LoginViewController: UIViewController, LoginViewControllerProtocol {
    let viewModel: LoginViewModel
    private var cancellables = Set<AnyCancellable>()
    weak var delegate: LoginViewControllerDelegate?
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.layer.borderWidth = 1.0
        tf.layer.cornerRadius = 5.0
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.layer.borderWidth = 1.0
        tf.layer.cornerRadius = 5.0
        return tf
    }()
    
    let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Login", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.isEnabled = false
        btn.alpha = 0.5
        return btn
    }()
    
    let errorLabel: UILabel = {
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
        
        emailTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        errorLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        
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
        emailTextField.addTarget(self, action: #selector(onEmailTextChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(onPasswordTextChanged), for: .editingChanged)
        
        viewModel.$isEmailValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.emailTextField.layer.borderColor = isValid ? UIColor.green.cgColor : UIColor.red.cgColor
                self?.updateLoginButtonState()
            }
            .store(in: &cancellables)
        
        viewModel.$isPasswordValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.passwordTextField.layer.borderColor = isValid ? UIColor.green.cgColor : UIColor.red.cgColor
                self?.updateLoginButtonState()
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.errorLabel.text = message
                self?.errorLabel.isHidden = message == nil
                if message != nil {
                    UIView.animate(withDuration: 0.3) {
                        self?.errorLabel.alpha = 1.0
                    }
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loginButton.isEnabled = !isLoading
                self?.loginButton.setTitle(isLoading ? "Loading..." : "Login", for: .normal)
                self?.loginButton.alpha = isLoading ? 0.5 : 1.0
            }
            .store(in: &cancellables)
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(onLoginButtonTapped), for: .touchUpInside)
    }
    
    @objc private func onEmailTextChanged(_ textField: UITextField) {
        emailChanged(textField.text ?? "")
    }
    
    @objc private func onPasswordTextChanged(_ textField: UITextField) {
        passwordChanged(textField.text ?? "")
    }
    
    @objc private func onLoginButtonTapped(_ sender: UIButton) {
        print("LoginViewController: Login button tapped")
        loginTapped { [weak self] success in
            print("LoginViewController: Login completion called, success: \(success)")
            if success {
                print("LoginViewController: Login successful")
                if let delegate = self?.delegate {
                    print("LoginViewController: Delegate is set, calling didLoginSuccessfully")
                    delegate.didLoginSuccessfully()
                } else {
                    print("LoginViewController: Delegate is nil, cannot call didLoginSuccessfully")
                }
            } else {
                print("LoginViewController: Login failed")
            }
        }
    }

    func loginTapped(completion: @escaping (Bool) -> Void) {
        print("LoginViewController: loginTapped called")
        viewModel.login(completion: completion)
    }
    
    func emailChanged(_ text: String) {
        viewModel.email = text
    }
    
    func passwordChanged(_ text: String) {
        viewModel.password = text
    }
    
    func updateLoginButtonState() {
        let isFormValid = viewModel.isEmailValid && viewModel.isPasswordValid
        loginButton.isEnabled = isFormValid && !viewModel.isLoading
        loginButton.alpha = loginButton.isEnabled ? 1.0 : 0.5
    }
}
