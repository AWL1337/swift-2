import Foundation
import Combine

class LoginViewModel {
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isEmailValid: Bool = false
    @Published var isPasswordValid: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    init(authService: AuthService) {
        self.authService = authService
        
        $email
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .map { $0.contains("@") && $0.contains(".") }
            .assign(to: \.isEmailValid, on: self)
            .store(in: &cancellables)
        
        $password
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .map { $0.count >= 6 }
            .assign(to: \.isPasswordValid, on: self)
            .store(in: &cancellables)
    }
    
    func login(completion: @escaping (Bool) -> Void) {
        isLoading = true
        authService.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let user):
                    print("Logged in user: \(user.name)")
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
}
