import UIKit
import Combine

protocol LoginViewControllerDelegate: AnyObject {
    func didLoginSuccessfully()
}

protocol LoginViewControllerProtocol: AnyObject {
    func showError(_ message: String)
}

class LoginViewController: UIViewController, LoginViewControllerProtocol {
    private let viewModel: LoginViewModel
    private var cancellables = Set<AnyCancellable>()
    weak var delegate: LoginViewControllerDelegate?
    
    // UI элементы дизайн-системы
    private let titleLabel = DSLabel()
    private let emailTextInput = DSTextInput()
    private let passwordTextInput = DSTextInput()
    private let loginButton = DSButton()
    private let errorLabel = DSLabel()
    private let stackView = DSStackView()
    
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
    }
    
    private func setupUI() {
        view.backgroundColor = DSTokens.Color.background
        
        // Конфигурация компонентов
        titleLabel.configure(with: DSLabelViewModel(text: "Login", style: .title))
        emailTextInput.configure(with: DSTextInputViewModel(
            placeholder: "Email",
            style: .default,
            onTextChanged: { [weak self] text in
                self?.viewModel.email.send(text)
            }
        ))
        passwordTextInput.configure(with: DSTextInputViewModel(
            placeholder: "Password",
            style: .secure,
            onTextChanged: { [weak self] text in
                self?.viewModel.password.send(text)
            }
        ))
        loginButton.configure(with: DSButtonViewModel(
            title: "Login",
            style: .primary,
            action: { [weak self] in
                self?.loginTapped()
            }
        ))
        errorLabel.configure(with: DSLabelViewModel(
            text: "",
            style: .caption,
            textColor: DSTokens.Color.error
        ))
        
        // Компоновка с помощью DSStackView
        stackView.configure(with: DSStackViewModel(
            axis: .vertical,
            alignment: .center,
            spacing: DSTokens.Spacing.medium,
            views: [titleLabel, emailTextInput, passwordTextInput, loginButton, errorLabel]
        ))
        
        view.addSubview(stackView)
        
        // Ограничения
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DSTokens.Spacing.large),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DSTokens.Spacing.large),
            
            emailTextInput.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            passwordTextInput.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            loginButton.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message = message {
                    self?.showError(message)
                }
            }
            .store(in: &cancellables)
        
        viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loginButton.isEnabled = !isLoading
            }
            .store(in: &cancellables)
        
        viewModel.loginResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success:
                    self?.delegate?.didLoginSuccessfully()
                case .failure(let error):
                    self?.showError(error.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }
    
    func showError(_ message: String) {
        errorLabel.configure(with: DSLabelViewModel(
            text: message,
            style: .caption,
            textColor: DSTokens.Color.error
        ))
    }
    
    private func loginTapped() {
        viewModel.login()
    }
}
