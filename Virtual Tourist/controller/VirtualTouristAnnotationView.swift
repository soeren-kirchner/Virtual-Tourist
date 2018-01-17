//
//  VirtualTouristAnnotationView.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 05.01.18.
//  Copyright © 2018 Sören Kirchner. All rights reserved.
//

import UIKit
import MapKit

class VirtualTouristAnnotationView: MKMarkerAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        markerTintColor = .pin
        glyphImage = UIImage(named: "binoculars")
        animatesWhenAdded = true
        isDraggable = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
