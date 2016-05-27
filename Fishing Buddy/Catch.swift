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
    @NSManaged var autoID: String                   //String representing autoID generated in Firebase as a key to reference this catch
    @NSManaged var catchOrigin: String              //Who caught this - either "My Catches" or "Other People's Catches"
    
    @NSManaged var latitude: Double                //Latitude of the catch
    @NSManaged var longitude: Double               //Longitude of the catch
    
    @NSManaged var species: String                  //Type of fish (i.e. largemouth bass, bream, crappie, etc)
    @NSManaged var weight: Double                   //Weight of the catch (lbs)
    @NSManaged var baitType: String                 //Type of bait used (i.e. plastic worm, crankbait, etc)
    @NSManaged var baitColor: String                //Color of bait used
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
    
    var jsonDictionary : NSDictionary {
        
        get {
            let catchJSON: NSDictionary = ["latitude": latitude,
                             "longitude": longitude,
                             "species": species,
                             "weight": weight,
                             "baitType": baitType,
                             "baitColor": baitColor]
            return catchJSON
        }
        
    }
    
    //MARK: Initializer
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(origin: String, userDeviceID: String, autoID: String, lat: Double, long: Double, species: String, weight: Double, baitType: String, baitColor: String, share: Bool, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Catch", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        //Set the devices Unique ID to distinguish this catch from other user's catches
        self.userDeviceID = userDeviceID
        
        //Set the autoID as a key to this catch in Firebase once the Firebase entry is made - used to find it in Firebase later
        self.autoID = autoID 
        
        self.catchOrigin = origin   //Who caught this? Me or someone else
        
        self.latitude = lat
        self.longitude = long
        self.species = species
        self.weight = weight
        self.baitType = baitType
        self.baitColor = baitColor
        
        self.share = share
        
    }
    
    func pinColor() -> UIColor {
        
        switch catchOrigin {
        case myCatchString:
            
            let myCatchColor = NSUserDefaults.standardUserDefaults().integerForKey(MY_CATCH_PIN_COLOR_KEY)
            if myCatchColor == 0 { return UIColor.greenColor() }
            else if myCatchColor == 1 { return UIColor.blueColor() }
            else { return UIColor.redColor() }
            
        case otherCatchString:
            
            let otherCatchColor = NSUserDefaults.standardUserDefaults().integerForKey(OTHER_CATCH_PIN_COLOR_KEY)
            if otherCatchColor == 0 { return UIColor.greenColor() }
            else if otherCatchColor == 1 { return UIColor.blueColor() }
            else { return UIColor.redColor() }
            
        default:
            
            return UIColor.redColor()
            
        }

    }
    
}
