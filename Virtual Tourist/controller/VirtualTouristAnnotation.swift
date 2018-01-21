//
//  VirtualTouristAnnotation.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 31.12.17.
//  Copyright © 2017 Sören Kirchner. All rights reserved.
//

import Foundation
import MapKit

class VirtualTouristAnnotation: MKPointAnnotation {
    
    var pin: Pin
    
    init(pin: Pin) {
        self.pin = pin
        super.init()
        coordinate.longitude = pin.longitude
        coordinate.latitude = pin.latitude
    }
    
}
