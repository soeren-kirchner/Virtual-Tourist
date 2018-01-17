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
    
    static let defaulLanguage = Language(name: "English", englishName: "English", code: "en")
    
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

        //cell.accessoryType = (languages[indexPath.row].code == Locale.preferredLanguages[0]) ? .checkmark : .none
        
        cell.name.text = languages[indexPath.row].name
        cell.englishName.text = languages[indexPath.row].englishName

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        let languageCode = languages[indexPath.row].code
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.set(getLanguage(forCode: languageCode)?.name, forKey: "userLanguage")
//        print(UserDefaults.standard.string(forKey: "AppleLanguages")!)
//        print(Locale.preferredLanguages[0])
        showAlert(title: NSLocalizedString("Restart", comment: "Title for restart dialog"), alert: "Please shutdown and restart the App to activate the language change.")
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
    
    private func getLanguage(forCode code: String) -> Language? {
        for language in languages {
            if language.code == code {
                return language
            }
        }
        return nil
    }
 
}
