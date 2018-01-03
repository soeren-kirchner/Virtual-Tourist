//
//  UIViewController.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 31.12.17.
//  Copyright © 2017 Sören Kirchner. All rights reserved.
//

import UIKit

extension UIViewController {

    func showAlert(title: String, alert: String) {
        DispatchQueue.main.async {
            let alertViewController = UIAlertController(title: title, message: alert, preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertViewController, animated: true, completion: nil)
        }
    }
    
}
