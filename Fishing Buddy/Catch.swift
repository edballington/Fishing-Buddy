//
//  Catch.swift
//  Fishing Buddy
//
//  Created by Ed Ballington on 4/3/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//

import CoreData
import UIKit
import MapKit

class Catch: NSManagedObject {
    
    //MARK: Properties
    
    @NSManaged var userDeviceID: String            //String representing the user's unique Device ID
    
    @NSManaged var latitude: Double                //Latitude of the catch
    @NSManaged var longitude: Double               //Longitude of the catch
    
    @NSManaged var species: String                  //Type of fish (i.e. largemouth bass, bream, crappie, etc)
    @NSManaged var weight: Double                   //Weight of the catch (lbs)
    @NSManaged var baitType: String?                 //Type of bait used (i.e. plastic worm, crankbait, etc)
    @NSManaged var baitColor: String?                //Color of bait used
    @NSManaged var share: Bool                      //Allow others to see the catch (post in Firebase DB)
    
    
    //MARK: Convenience Getter Methods
    
    var coordinate : CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    var weightPounds : Int {
        get {
            return Int(self.weight)
        }
    }
    
    var weightOunces : Int {
        get {
            let ounces = Int(modf(self.weight).1*16)
            return(ounces)
        }
    }
    
    
    //MARK: Initializer
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(lat: Double, long: Double, species: String, weight: Double, baitType: String?, baitColor: String?, share: Bool, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Catch", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.latitude = lat
        self.longitude = long
        self.species = species
        self.weight = weight
        
        if let _ = baitType {
            self.baitType = baitType
        }
        
        if let _ = baitColor {
            self.baitColor = baitColor
        }
        
        self.share = share
        
    }
    
}
