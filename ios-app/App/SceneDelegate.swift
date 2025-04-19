import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let router = AppRouter(window: window)
        let expenseService = NetworkExpenseService()
        let coordinator = AppCoordinator(router: router, expenseService: expenseService)
        self.appCoordinator = coordinator
        coordinator.start()
    }
}
