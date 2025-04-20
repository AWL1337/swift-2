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
        print("AppRouter: Initialized with window")
    }
    
    func start() {
        print("AppRouter: Starting")
        showLoginScreen()
    }
    
    func showLoginScreen() {
        print("AppRouter: Showing login screen")
        let authService = MockAuthService()
        let viewModel = LoginViewModel(authService: authService)
        let loginVC = LoginViewController(viewModel: viewModel)
        _navigationController = UINavigationController(rootViewController: loginVC)
        print("AppRouter: Navigation controller created: \(_navigationController != nil)")
        window.rootViewController = _navigationController
        window.makeKeyAndVisible()
    }
    
    func showExpensesScreen() {
        print("AppRouter: Showing expenses screen")
        guard let navController = _navigationController else {
            print("AppRouter: Error: Navigation controller is nil")
            return
        }
        let expenseService = NetworkExpenseService()
        let viewModel = ExpensesViewModel(expenseService: expenseService)
        let expensesVC = ExpensesViewController(viewModel: viewModel)
        print("AppRouter: Pushing ExpensesViewController")
        navController.pushViewController(expensesVC, animated: true)
    }
}
