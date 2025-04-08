import UIKit

class AppRouter {
    private let window: UIWindow
    private var navigationController: UINavigationController?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let authService = MockAuthService()
        let viewModel = LoginViewModel(authService: authService)
        let loginVC = LoginView(viewModel: viewModel)
        navigationController = UINavigationController(rootViewController: loginVC)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
