//
//  Settings.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 10.12.17.
//  Copyright © 2017 Sören Kirchner. All rights reserved.
//

import Foundation

class Settings {
    
    static let shared = Settings()
    
    let languages = ["en": NSLocalizedString("en", comment: "English"),
                     "de": NSLocalizedString("de", comment: "German"),
                     "he": NSLocalizedString("he", comment: "Hebrew")]
    
    let preferredLanguage = Locale.preferredLanguages[0];
    
    func set(_ language : String) {
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
}
