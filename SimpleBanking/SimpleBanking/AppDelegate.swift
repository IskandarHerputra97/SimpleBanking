//
//  AppDelegate.swift
//  SimpleBanking
//
//  Created by Iskandar Herputra Wahidiyat on 29/01/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NotificationCenter.default.addObserver(self, selector: #selector(showMainViewController), name: .loginStateChange, object: nil)
        showMainViewController()
        
        return true
    }

    //MARK: - Setup
    @objc private func showMainViewController() {
        if self.window == nil {
            self.window = UIWindow()
        }
        
        var landingPageVC: UIViewController = createNonLoginLandingPage()
        
        if UserHelper.isUserLogin() {
            let homeController = HomeViewController()
            landingPageVC = UINavigationController(rootViewController: homeController)
        }
        
        self.window?.rootViewController = landingPageVC
        self.window?.makeKeyAndVisible()
    }
    
    private func createNonLoginLandingPage() -> UIViewController {
        let landingPageViewController: LoginViewController = LoginViewController()
        let navController: UINavigationController = UINavigationController(rootViewController: landingPageViewController)
        return navController
    }
}
