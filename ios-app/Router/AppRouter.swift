import UIKit

protocol Router {
    func start()
    func showLoginScreen()
    func showExpensesScreen()
    var navigationController: UINavigationController? { get }
}

class AppRouter: Router {
    private let window: UIWindow
    private var _navigationController: UINavigationController?
    
    var navigationController: UINavigationController? {
        return _navigationController
    }
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        showLoginScreen()
    }
    
    func showLoginScreen() {
        let authService = NetworkAuthService()
        let viewModel = LoginViewModel(authService: authService)
        let loginVC = LoginViewController(viewModel: viewModel)
        _navigationController = UINavigationController(rootViewController: loginVC)
        window.rootViewController = _navigationController
        window.makeKeyAndVisible()
    }
    
    func showExpensesScreen() {
        print("Showing expenses screen")
        guard let navController = _navigationController else {
            print("Error: Navigation controller is nil")
            return
        }
        let expenseService = NetworkExpenseService()
        let viewModel = ExpensesViewModel(expenseService: expenseService)
        let expensesVC = ExpensesViewController(viewModel: viewModel)
        navController.pushViewController(expensesVC, animated: true)
    }
}
