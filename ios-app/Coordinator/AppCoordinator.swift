import UIKit
import Combine

class AppCoordinator: ExpensesViewControllerDelegate, LoginViewControllerDelegate, ExpenseSelectionDelegate {
    private let router: Router
    private var cancellables = Set<AnyCancellable>()
    private let expenseService: ExpenseService
    
    init(router: Router, expenseService: ExpenseService = NetworkExpenseService()) {
        self.router = router
        self.expenseService = expenseService
    }
    
    func start() {
            router.start()
            if let navController = router.navigationController {
                if let loginVC = navController.topViewController as? LoginViewController {
                    loginVC.delegate = self
                }
                if let expensesVC = navController.topViewController as? ExpensesViewController {
                    expensesVC.delegate = self
                    expensesVC.selectionDelegate = self
                }
            }
        }
    
    func didSelectExpense(_ expense: ExpenseItem) {
        print("AppCoordinator: Selected expense: \(expense.amount) - \(expense.category)")
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
