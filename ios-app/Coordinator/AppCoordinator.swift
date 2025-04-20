import UIKit
import Combine

class AppCoordinator: ExpensesViewControllerDelegate {
    private let router: Router
    private var cancellables = Set<AnyCancellable>()
    private let expenseService: ExpenseService
    
    init(router: Router, expenseService: ExpenseService = NetworkExpenseService()) {
        self.router = router
        self.expenseService = expenseService
    }
    
    func start() {
        router.start()
    }
    
    func didRequestLogout() {
        DispatchQueue.main.async { [weak self] in
            do {
                try self?.expenseService.clearCache()
                print("Cache cleared successfully")
            } catch {
                print("Failed to clear cache: \(error)")
            }
            self?.router.showLoginScreen()
        }
    }
}
