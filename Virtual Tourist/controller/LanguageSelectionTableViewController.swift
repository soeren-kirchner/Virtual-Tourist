//
//  LanguageSelectionTableViewController.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 10.12.17.
//  Copyright © 2017 Sören Kirchner. All rights reserved.
//

import UIKit

class LanguageSelectionTableViewController: UITableViewController {

    let languageCellIdentifier = "LanguageSelectionCell"
    
    struct Language {
        let name: String
        let englishName: String
        let code: String
    }
    
    let languages = [
        Language(name: "English", englishName: "English", code: "en"),
        Language(name: "Deutsch", englishName: "German", code: "de"),
        Language(name: "עברית‬", englishName: "Hebrew", code: "he")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }

 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: languageCellIdentifier, for: indexPath) as! LanguageSelectionTableViewCell

        cell.name.text = languages[indexPath.row].name
        cell.englishName.text = languages[indexPath.row].englishName

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        let languageCode = languages[indexPath.row].code
        
        
        showAlert(title: NSLocalizedString("Restart", comment: "Title for restart dialog"), alert: "Please shutdown and restart the App to activate the language change.")
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
 
}
