//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 09.12.17.
//  Copyright © 2017 Sören Kirchner. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // test
        print(Settings.shared.preferredLanguage)
        Settings.shared.set("de")
        print(Settings.shared.preferredLanguage)

        UINavigationBar.appearance().tintColor = UIColor(named: "BarTint")
        return true
    }

}

