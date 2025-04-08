import Foundation

protocol LoginController {
    
    func loadView()
        
    func viewDidLoad()
    
    func loginButtonTapped()
    
    func showError(_ message: String)
}
