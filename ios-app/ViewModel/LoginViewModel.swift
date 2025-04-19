import Combine
import Foundation

class LoginViewModel {
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var email: String = "" {
        didSet { validateEmail() }
    }
    @Published var password: String = "" {
        didSet { validatePassword() }
    }
    let errorMessage = CurrentValueSubject<String?, Never>(nil)
    let isLoading = CurrentValueSubject<Bool, Never>(false)
    let isEmailValid = CurrentValueSubject<Bool, Never>(false)
    let isPasswordValid = CurrentValueSubject<Bool, Never>(false)
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func login(completion: @escaping (Bool) -> Void) {
        guard isEmailValid.value, isPasswordValid.value else {
            errorMessage.send("Please enter a valid email and password")
            return
        }
        
        isLoading.send(true)
        authService.login(email: email, password: password) { [weak self] result in
            self?.isLoading.send(false)
            switch result {
            case .success(let user):
                print("Logged in user: \(user.name)")
                completion(true)
            case .failure(let error):
                self?.errorMessage.send(error.localizedDescription)
                completion(false)
            }
        }
    }
    
    private func validateEmail() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        isEmailValid.send(predicate.evaluate(with: email) && !email.isEmpty)
    }
    
    private func validatePassword() {
        isPasswordValid.send(password.count >= 6)
    }
}
