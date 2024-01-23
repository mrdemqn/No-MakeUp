//
//  SceneDelegate.swift
//  Instaura
//
//  Created by Димон on 16.11.23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let type = connectionOptions.shortcutItem?.type
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()
        let viewController = MainViewController()
        viewController.shortcutType = type
        let navigationController = FadeNavigationController(rootViewController: viewController)
        window?.rootViewController = navigationController
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let viewController = MainViewController()
        viewController.shortcutType = shortcutItem.type
        let navigationController = FadeNavigationController(rootViewController: viewController)
        window?.rootViewController = navigationController
        completionHandler(true)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
//        let application = UIApplication.shared
//        application.shortcutItems = [
//            UIApplicationShortcutItem(type: "",
//                                      localizedTitle: "Открыть календарь",
//                                      localizedSubtitle: "Нажмите, чтобы открыть экран с календарём",
//                                      icon: UIApplicationShortcutIcon(systemImageName: "calendar.badge.clock")),
//            UIApplicationShortcutItem(type: "",
//                                      localizedTitle: "Новая запись",
//                                      localizedSubtitle: "Нажмите, чтобы создать новую запись",
//                                      icon: UIApplicationShortcutIcon(systemImageName: "plus.viewfinder")),
//            ]
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

