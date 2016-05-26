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
    
    var origin: originType
    var title: String?
    var weight: String
    var lureTypeAndColor: String
    var coordinate: CLLocationCoordinate2D
    
    init(origin: originType, species: String, weight: String, lureTypeAndColor: String, coordinate: CLLocationCoordinate2D) {
        
        self.origin = origin
        self.title = species
        self.weight = weight
        self.lureTypeAndColor = lureTypeAndColor
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return weight
    }
    
    func pinColor() -> UIColor {
        switch origin {
        case originType.MyCatch:
            
            let myCatchColor = NSUserDefaults.standardUserDefaults().integerForKey(MY_CATCH_PIN_COLOR_KEY)
            if myCatchColor == 0 { return UIColor.greenColor() }
            else if myCatchColor == 1 { return UIColor.blueColor() }
            else { return UIColor.redColor() }
            
        case originType.OtherCatch:
            
            let otherCatchColor = NSUserDefaults.standardUserDefaults().integerForKey(OTHER_CATCH_PIN_COLOR_KEY)
            if otherCatchColor == 0 { return UIColor.greenColor() }
            else if otherCatchColor == 1 { return UIColor.blueColor() }
            else { return UIColor.redColor() }
            
        }
    }

}
