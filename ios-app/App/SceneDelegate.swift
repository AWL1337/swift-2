import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appRouter: AppRouter?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let router = AppRouter(window: window)
        self.appRouter = router
        router.start()
    }
}
