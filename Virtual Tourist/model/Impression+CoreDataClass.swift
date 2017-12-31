//
//  Impression+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 26.12.17.
//  Copyright © 2017 Sören Kirchner. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Impression)
public class Impression: NSManagedObject {

    convenience init(url: URL, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Impression", in: context) {
            self.init(entity: entity, insertInto: context)
            self.url = url
        }
        else {
            fatalError("unable to find entity")
        }
    }
    
}
