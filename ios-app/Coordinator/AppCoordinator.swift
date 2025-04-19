import UIKit
import Combine

class AppCoordinator {
    private let router: Router
    private var cancellables = Set<AnyCancellable>()
    
    init(router: Router) {
        self.router = router
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
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
}
