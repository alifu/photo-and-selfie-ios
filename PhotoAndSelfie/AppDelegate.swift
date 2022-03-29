//
//  AppDelegate.swift
//  PhotoAndSelfie
//
//  Created by alifu on 29/03/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let parent = storyboard.instantiateViewController(withIdentifier: "ParentViewController") as? ParentViewController {
            let navigation = UINavigationController(rootViewController: parent)
            window?.rootViewController = navigation
        }
        
        return true
    }

   

}

