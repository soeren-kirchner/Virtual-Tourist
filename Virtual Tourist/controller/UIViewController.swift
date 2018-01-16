//
//  UIViewController.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 31.12.17.
//  Copyright © 2017 Sören Kirchner. All rights reserved.
//

import UIKit

extension UIViewController {
    
    struct LabelText{
        static let ok = NSLocalizedString("OK", comment: "okay")
        static let cancel = NSLocalizedString("Cancel", comment: "cancel")
    }

    func showAlert(title: String, alert: String) {
        DispatchQueue.main.async {
            let alertViewController = UIAlertController(title: title, message: alert, preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction(title: LabelText.ok, style: .default, handler: nil))
            self.present(alertViewController, animated: true, completion: nil)
        }
    }
    
    func showOkayCancel(title: String, question: String, completionHandler: @escaping (Bool) -> Void ) {
        DispatchQueue.main.async {
            let alertViewController = UIAlertController(title: title, message: question, preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction(title: LabelText.ok, style: .default, handler: { (action: UIAlertAction!) in
                completionHandler(true)
            }))
            alertViewController.addAction(UIAlertAction(title: LabelText.cancel, style: .default, handler: { (action: UIAlertAction!) in
                completionHandler(false)
            }))
            self.present(alertViewController, animated: true, completion: nil)
        }
    }
    
    func setDarkMode() {
        if let navBar = navigationController?.navigationBar {
            if isDarkMode() {
                navBar.barStyle = .blackTranslucent
            } else {
                navBar.barStyle = .default
            }
        }
    }
    
    func isDarkMode() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaults.SettingsKeys.darkmode)
    }
    
    func saveContext() {
        do {
            try CoreDataStack.shared.saveContext()
        }
        catch {
            showAlert(title: NSLocalizedString("ERROR", comment: "ERROR"), alert: NSLocalizedString("An Error occured while storing data", comment: "Error Message for the user when the App cannot store data"))
        }
    }
    
}

