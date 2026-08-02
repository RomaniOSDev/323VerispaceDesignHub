import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let studioColor = UIColor(named: "AppBackground") ?? UIColor(red: 0.20, green: 0.23, blue: 0.39, alpha: 1)

        let hosting = UIHostingController(rootView: ContentView())
        hosting.view.backgroundColor = studioColor

        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = studioColor
        window?.rootViewController = hosting
        window?.makeKeyAndVisible()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.requiresExclusiveTouchType = false
        window?.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        window?.endEditing(true)
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
