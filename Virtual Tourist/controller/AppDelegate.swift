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
    
    let stack = CoreDataStack.shared
  
    fileprivate func saveContext() {
        print("try to save context")
        do {
            try stack.saveContext()
        }
        catch {
            print("error")
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // test
        print(Settings.shared.preferredLanguage)
        Settings.shared.set("de")
        print(Settings.shared.preferredLanguage)
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print(paths[0])
        
        //preloadData()
        
        //stack.autoSave(1)
        

        return true
    }

    func preloadData() {
        do {
            try stack.dropAllData()
        }
        catch {
            print("unable to drop all data from stack")
        }
    }
    
    
}

