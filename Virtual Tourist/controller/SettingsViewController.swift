//
//  SettingsViewController.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 10.12.17.
//  Copyright © 2017 Sören Kirchner. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UITableViewController {

    let stack = CoreDataStack.shared
    let app = UIApplication.shared
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        darkModeSwitch.setOn(UserDefaults.standard.bool(forKey: UserDefaults.SettingsKeys.darkmode), animated: false)
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        print("delete all")
        showOkayCancel(title: "Delete all Data", question: "Are you sure to delete all your content") { (okay) in
            if okay {
                try? self.stack.dropAllData()
            }
        }
    }
    
    @IBAction func setDarkMode(_ sender: Any) {
        UserDefaults.standard.set(darkModeSwitch.isOn, forKey: UserDefaults.SettingsKeys.darkmode)
        setDarkMode()
    }
    
    

}
