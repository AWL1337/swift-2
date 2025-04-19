import Foundation

class LoginViewModel {
    private let authService: AuthService
    var email: String = "" {
        didSet { validateEmail() }
    }
    var password: String = "" {
        didSet { validatePassword() }
    }
    var errorMessage: Observable<String?> = Observable(nil)
    var isLoading: Observable<Bool> = Observable(false)
    var isEmailValid: Observable<Bool> = Observable(false)
    var isPasswordValid: Observable<Bool> = Observable(false)
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func login(completion: @escaping (Bool) -> Void) {
        guard isEmailValid.value, isPasswordValid.value else {
            errorMessage.value = "Please enter a valid email and password"
            return
        }
        
        isLoading.value = true
        authService.login(email: email, password: password) { [weak self] result in
            self?.isLoading.value = false
            switch result {
            case .success(let user):
                print("Logged in user: \(user.name)")
                completion(true)
            case .failure(let error):
                self?.errorMessage.value = error.localizedDescription
                completion(false)
            }
        }
    }
    
    private func validateEmail() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        isEmailValid.value = predicate.evaluate(with: email) && !email.isEmpty
    }
    
    private func validatePassword() {
        isPasswordValid.value = password.count >= 6
    }
}

class Observable<T> {
    var value: T {
        didSet {
            DispatchQueue.main.async {
                self.listener?(self.value)
            }
        }
    }
    private var listener: ((T) -> Void)?
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ listener: @escaping (T) -> Void) {
        self.listener = listener
        DispatchQueue.main.async {
            listener(self.value)
        }
    }
}
