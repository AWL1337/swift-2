import Foundation
import Combine

class LoginViewModel {
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    let email = CurrentValueSubject<String, Never>("")
    let password = CurrentValueSubject<String, Never>("")
    let errorMessage = CurrentValueSubject<String?, Never>(nil)
    let isLoading = CurrentValueSubject<Bool, Never>(false)
    let loginResult = PassthroughSubject<Result<Void, Error>, Never>()
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func login() {
        guard !email.value.isEmpty, !password.value.isEmpty else {
            errorMessage.send("Email and password cannot be empty")
            loginResult.send(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email and password cannot be empty"])))
            return
        }
        
        isLoading.send(true)
        authService.login(email: email.value, password: password.value) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading.send(false)
                switch result {
                case .success:
                    self?.loginResult.send(.success(()))
                case .failure(let error):
                    self?.errorMessage.send(error.localizedDescription)
                    self?.loginResult.send(.failure(error))
                }
            }
        }
    }
}
