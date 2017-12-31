//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 26.12.17.
//  Copyright © 2017 Sören Kirchner. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation

@objc(Pin)
public class Pin: NSManagedObject {

    convenience init(longitude: Double, latitude: Double, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: entity, insertInto: context)
            self.longitude = longitude
            self.latitude = latitude
        }
        else {
            fatalError("unable to find entity")
        }
    }
    
    convenience init(coordinates: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        self.init(longitude: coordinates.longitude, latitude: coordinates.latitude, context: context)
    }
    
}
