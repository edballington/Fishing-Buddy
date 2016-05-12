//
//  CatchAnnotation.swift
//  Fishing Buddy
//
//  Created by Ed Ballington on 5/4/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//

import UIKit
import MapKit

class CatchAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let weight: String
    let lureTypeAndColor: String
    let coordinate: CLLocationCoordinate2D
    
    init(species: String, weight: String, lureTypeAndColor: String, coordinate: CLLocationCoordinate2D) {
        self.title = species
        self.weight = weight
        self.lureTypeAndColor = lureTypeAndColor
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return weight
    }

}
