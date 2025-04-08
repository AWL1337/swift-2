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

class NetworkAuthService: AuthService {
    private let url = URL(string: "https://mp43e19ef9d53a116f40.free.beeceptor.com/auth")!
    
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password]
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let responseString = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            if responseString.trimmingCharacters(in: .whitespacesAndNewlines) == "true" {
                let user = User(id: UUID(), email: email, password: password, name: "Test User")
                completion(.success(user))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid email or password"])))
            }
        }.resume()
    }
}
