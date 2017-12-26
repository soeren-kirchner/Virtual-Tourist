//
//  Impression+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 26.12.17.
//  Copyright © 2017 Sören Kirchner. All rights reserved.
//
//

import Foundation
import CoreData


extension Impression {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Impression> {
        return NSFetchRequest<Impression>(entityName: "Impression")
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var url: URL?
    @NSManaged public var pin: Pin?

}
