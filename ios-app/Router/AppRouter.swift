import UIKit

class AppRouter {
    private let window: UIWindow
    private var navigationController: UINavigationController?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let authService = NetworkAuthService()
        let viewModel = LoginViewModel(authService: authService)
        let loginVC = LoginView(viewModel: viewModel)
        navigationController = UINavigationController(rootViewController: loginVC)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        viewModel.login { [weak self] success in
                    if success {
                        DispatchQueue.main.async {
                            self?.showExpensesScreen()
                        }
                    }
                }
    }
    
    private func showExpensesScreen() {
        let expenseService = NetworkExpenseService()
        let viewModel = ExpensesViewModel(expenseService: expenseService)
        let expensesVC = ExpensesViewController(viewModel: viewModel)
        navigationController?.pushViewController(expensesVC, animated: true)
    }
}
