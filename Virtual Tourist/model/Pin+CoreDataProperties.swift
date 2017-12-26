//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 26.12.17.
//  Copyright © 2017 Sören Kirchner. All rights reserved.
//
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin")
    }

    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var impressions: NSSet?

}

// MARK: Generated accessors for impressions
extension Pin {

    @objc(addImpressionsObject:)
    @NSManaged public func addToImpressions(_ value: Impression)

    @objc(removeImpressionsObject:)
    @NSManaged public func removeFromImpressions(_ value: Impression)

    @objc(addImpressions:)
    @NSManaged public func addToImpressions(_ values: NSSet)

    @objc(removeImpressions:)
    @NSManaged public func removeFromImpressions(_ values: NSSet)

}
