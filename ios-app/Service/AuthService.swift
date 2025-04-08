import Foundation

protocol AuthService {
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
}

class MockAuthService: AuthService {
    private let mockUser = User(id: UUID(), email: "test@example.com", password: "password123", name: "Test User")
    
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if email == self.mockUser.email && password == self.mockUser.password {
                completion(.success(self.mockUser))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid email or password"])))
            }
        }
    }
}
