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
    
    @IBAction func deleteAll(_ sender: Any) {
        print("delete all")
        showOkayCancel(title: "Delete all Data", question: "Are you sure to delete all your content") { (okay) in
            if okay {
                print("okay")
                //CoreDataStack.dropAllData(stack: )
            } else {
                print("cancel")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }


}
