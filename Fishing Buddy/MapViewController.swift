//
//  MapViewController.swift
//  Fishing Buddy
//
//  Created by Ed Ballington on 3/29/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation
import Firebase

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate {
    
    //MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    
    //MARK: Actions
    
    @IBAction func refreshMapView(sender: AnyObject) {
        refreshCatches()
    }
    
    
    //MARK: Properties
    
    var mapCenterLocation: CLLocationCoordinate2D?
    
    
    //MARK: Constants
    
    let firebaseRef = Firebase(url: "https://blistering-heat-7872.firebaseio.com/")
    
    /* Devices Unique ID to distinguish my catches from other user's catches */
    let userDeviceID = UIDevice.currentDevice().identifierForVendor!.UUIDString
    
    
    //MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        
        //Do these things once when the app first starts up
        super.viewDidLoad()
        mapView.delegate = self
        
        setMapInitialState()
    
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //Do these things every time the mapview appears
        super.viewWillAppear(true)
        
        //If a center coordinate has been set then change to it - otherwise leave map as is
        if let mapCoordinate = mapCenterLocation {
            self.mapView.setCenterCoordinate(mapCoordinate, animated: true)
        }
        
        refreshCatches()
        
    }


    //MARK: Convenience Methods
    func setMapInitialState() {
        
        mapView.showsUserLocation = true
        
    }
    
    /* Retrieves all Catch objects from Core Data */
    func fetchAllCatches() -> [Catch]? {

        var foundCatches = [Catch]()
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Catch")
        
        // Execute the Fetch Request
        do {
            foundCatches = try sharedContext.executeFetchRequest(fetchRequest) as! [Catch]
        } catch {
            print("Error retrieving Catches from CoreData: \(error)")
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.showAlertView("Cannot load saved Catches")
            })
        }
        
        // Return the results, cast to an array of Catch objects
        return foundCatches
    }
    
    /* Refresh catches and load from Firebase */
    func refreshCatches() {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.progressIndicator.startAnimating()
        }
        
        // Load catches from Core Data and add to map if there are any
        if let catches = fetchAllCatches() {
            
            /* First delete all of the catches in the managed object context that aren't mine so they won't get downloaded twice */
            for fish in catches {
                if fish.userDeviceID != self.userDeviceID {
                    
                    let otherFish = fish as NSManagedObject
                    self.sharedContext.deleteObject(otherFish)
                }
            }
            
            /* Second, save the context after deletion */
            CoreDataStackManager.sharedInstance().saveContext()
            
        }
        
        /* Third, get a new set of other user's catches from Firebase - when done loading then add all catches to the map */
        getCatchesFromFirebase({ (success) in
            if success {
                let newCatches = self.fetchAllCatches()
                
                self.addCatchesToMap(newCatches!)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.progressIndicator.stopAnimating()
                })
            }
        })
        
    }
    
    /* Add Catches to mapView from array */
    func addCatchesToMap(catches: [Catch]) {
        
        /* First remove any existing pins so they don't get added again on top of old ones */
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        var catchPinColor: UIColor
        
        for fish in catches {
            
            if fish.catchOrigin == "My Catches" {
                catchPinColor = UIColor.greenColor()
            } else {
                catchPinColor = UIColor.redColor()
            }
            
            let annotation = CatchAnnotation(pinColor: catchPinColor , species: fish.species, weight: "\(fish.weightPounds) lbs \(fish.weightOunces) oz", lureTypeAndColor: "\(fish.baitType) \(fish.baitColor)", coordinate: fish.coordinate)
            
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "catchPin")
            
            annotationView.animatesDrop = true
            annotationView.draggable = false
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.mapView.addAnnotation(annotation)
            })
            
        }
        
        
    }
    
    /* Method to display an alertView with a single OK button to acknowledge */
    func showAlertView(message: String?) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /* Method to query other user's catches from Firebase db and store them in Core Data */
    func getCatchesFromFirebase(completion: (success: Bool) -> Void) {
        
        firebaseRef.childByAppendingPath("users").queryOrderedByChild("users").observeSingleEventOfType(.Value, withBlock: { firebaseSnapshot in
            
            if let catchDictionary = firebaseSnapshot.value as? NSDictionary {
                
                for (user, catches) in catchDictionary {
                    //Only get the catch data for the other users
                    if (user as! String) != self.userDeviceID {
                        
                        //Iterate over all of their catches
                        for fish in (catches as! NSDictionary) {
                            
                            let fishDictionary = (fish.value as! NSDictionary)
                            
                                //Create a new Catch Object in shared context from the retrieved dictionary
                            let _ = Catch(origin: "Other People's Catches", userDeviceID: user as! String,lat: fishDictionary["latitude"] as! Double, long: fishDictionary["longitude"] as! Double, species: fishDictionary["species"] as! String, weight: fishDictionary["weight"] as! Double, baitType: fishDictionary["baitType"] as! String, baitColor: fishDictionary["baitColor"] as! String, share: true, context: self.sharedContext)
                            
                                CoreDataStackManager.sharedInstance().saveContext()
                            
                        }
                        
                        completion(success: true)
                    }
                }
                
            } else {
                completion(success: false)
            }
        })
        

    }
    
    
    //MARK: MapView Delegate Methods
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? CatchAnnotation {
            let identifier = "catchPin"
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                
                let colorPointAnnotation = annotation as! CatchAnnotation
                view.pinTintColor = colorPointAnnotation.pinColor
                
                //Assign the correct fish image based on the catch species value
                let catchImage = UIImage(named: annotation.title!)
                let catchImageView = UIImageView.init(image: catchImage)
                
                view.leftCalloutAccessoryView = catchImageView
                
            }
            return view
        }
        return nil
        
    }
    

    //MARK: Core Data Convenience
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()

}

