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
        if let navController = router.navigationController,
           let loginVC = navController.topViewController as? LoginViewControllerProtocol {
            bindLoginViewModel(from: loginVC)
        }
    }
    
    private func bindLoginViewModel(from loginVC: LoginViewControllerProtocol) {
        loginVC.viewModel.isLoading
            .filter { !$0 }
            .sink { [weak self] (_: Bool) in
                loginVC.viewModel.login { success in
                    if success {
                        DispatchQueue.main.async {
                            self?.router.showExpensesScreen()
                            if let navController = self?.router.navigationController,
                               let expensesVC = navController.topViewController as? ExpensesViewControllerProtocol {
                                (expensesVC as? ExpensesViewController)?.delegate = self
                            }
                        }
                    }
                }
            }
            .store(in: &cancellables)
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
