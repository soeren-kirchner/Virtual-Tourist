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
}

