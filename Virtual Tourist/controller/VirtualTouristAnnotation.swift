//
//  VirtualTouristAnnotation.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 31.12.17.
//  Copyright © 2017 Sören Kirchner. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class VirtualTouristAnnotation: MKPointAnnotation {
    
    var pin: Pin {
        set {
            super.coordinate.longitude = self.pin.longitude
            super.coordinate.latitude = self.pin.latitude
        }
        get {
            return self.pin
        }
    }
    
    init(pin: Pin) {
        super.init()
        self.pin = pin
    }
    
}
