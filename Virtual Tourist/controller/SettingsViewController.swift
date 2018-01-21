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
    @IBOutlet weak var languageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initValues()
    }
    
    fileprivate func initValues() {
        darkModeSwitch.setOn(UserDefaults.standard.bool(forKey: UserDefaults.SettingsKeys.darkmode), animated: false)
        if let language = UserDefaults.standard.string(forKey: "userLanguage") {
            languageLabel.text = language
        }
        else {
            languageLabel.text = LanguageSelectionTableViewController.defaulLanguage.name
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initValues()
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        showOkayCancel(title: NSLocalizedString("Delete all Data", comment: "Delete all Data"), question: NSLocalizedString("Are you sure to delete all your content", comment: "Are you sure to delete all your content")) { (okay) in
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
