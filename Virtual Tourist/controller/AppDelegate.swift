//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 09.12.17.
//  Copyright © 2017 Sören Kirchner. All rights reserved.
//

import UIKit
import MapKit

typealias JSONDictionary = [String:AnyObject]
typealias JSONArray = [JSONDictionary]
typealias ParametersArray = [String:AnyObject]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
}

