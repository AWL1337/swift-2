import UIKit
import Combine

class AppCoordinator: ExpensesViewControllerDelegate, LoginViewControllerDelegate {
    private let router: Router
    private var cancellables = Set<AnyCancellable>()
    private let expenseService: ExpenseService
    
    init(router: Router, expenseService: ExpenseService = NetworkExpenseService()) {
        self.router = router
        self.expenseService = expenseService
        print("AppCoordinator: Initialized")
    }
    
    func start() {
        print("AppCoordinator: Starting app")
        router.start()
        if let navController = router.navigationController {
            if let loginVC = navController.topViewController as? LoginViewController {
                print("AppCoordinator: Setting delegate for LoginViewController")
                loginVC.delegate = self
            } else {
                print("AppCoordinator: Failed to cast topViewController to LoginViewController, actual type: \(type(of: navController.topViewController))")
            }
        } else {
            print("AppCoordinator: Navigation controller is nil")
        }
    }
    
    func didLoginSuccessfully() {
        print("AppCoordinator: didLoginSuccessfully called")
        print("AppCoordinator: Navigation controller is: \(router.navigationController != nil ? "set" : "nil")")
        router.showExpensesScreen()
    }
    
    func didRequestLogout() {
        print("AppCoordinator: didRequestLogout called")
        do {
            try expenseService.clearCache()
            print("Cache cleared successfully")
        } catch {
            print("Failed to clear cache: \(error)")
        }
        router.showLoginScreen()
    }
}
