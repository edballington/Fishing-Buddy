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
    var prevConnected = true            //Flag to indicate whether connection to Firebase was previously connected
    var connectionTimer = NSTimer()     //Timer for detecting Firebase connect/disconnect
    
    
    //MARK: Constants
    
    /* Devices Unique ID to distinguish my catches from other user's catches */
    let userDeviceID = UIDevice.currentDevice().identifierForVendor!.UUIDString
    let myCatchPinID = "myCatchPin"
    let otherCatchPinID = "otherCatchPin"
    let connectionTime = 3.0        //Timeout value for detecting Firebase server connected/disconnected state
    
    
    //MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        
        //Do these things once when the app first starts up
        super.viewDidLoad()
        
        mapView.delegate = self
        
        prevConnected = true    //When view is loaded assume connection is up to begin with
        setupConnectionMonitor()
    
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //Do these things every time the mapview appears
        super.viewWillAppear(true)
        
        setMapInitialState()
        
        //If a center coordinate has been set then change to it - otherwise leave map as is
        if let mapCoordinate = mapCenterLocation {
            self.mapView.setCenterCoordinate(mapCoordinate, animated: true)
        }
        
        refreshCatches()
        
    }


    //MARK: Convenience Methods
    func setMapInitialState() {
        
        mapView.showsUserLocation = NSUserDefaults.standardUserDefaults().boolForKey(USER_LOCATION_SWITCH_KEY)
        
    }
    
    /* Monitors Firebase connection status and alerts the user when connection is lost/restored */
    func setupConnectionMonitor() {
        
        let connectedRef = FIRDatabase.database().referenceWithPath(".info/connected")
        connectedRef.observeEventType(.Value, withBlock: {snapshot in
                
            let connected = snapshot.value as? Bool
            if connected != nil && connected! {
                print("*******Connection restored*******")
                
                self.connectionTimer.invalidate()    //Cancel any previous timer
                self.connectionTimer = NSTimer.scheduledTimerWithTimeInterval(self.connectionTime, target: self, selector: #selector(MapViewController.alertConnectionRestored), userInfo: nil, repeats: false)
                
            } else {
                print("*****Connection lost******")
                
                self.connectionTimer.invalidate()    //Cancel any previous timer
                self.connectionTimer = NSTimer.scheduledTimerWithTimeInterval(self.connectionTime, target: self, selector: #selector(MapViewController.alertConnectionDown), userInfo: nil, repeats: false)
            }
            
        })
        
    }
    
    func alertConnectionRestored() {
        
        //First check whether this is a change in state from the connection being down - if not do nothing
        if !self.prevConnected {
            self.showAlertView("Alert", message: "Connection to server restored - all pending catches will be updated")
            self.prevConnected = true
            self.refreshCatches()
        }
        
    }
    
    func alertConnectionDown() {
        
        //First check whether this is a change in state from the connection being up - if not do nothing
        if self.prevConnected {
            self.showAlertView("Alert", message: "Connection to server lost - catches by others may not be up to date")
            self.prevConnected = false
        }
        
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
                self.showAlertView("Error", message: "Cannot load saved catches")
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
            
                let newCatches = self.fetchAllCatches()
                
                self.addCatchesToMap(newCatches!)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.progressIndicator.stopAnimating()
                })
            
        })
        
    }
    
    /* Add Catches to mapView from array */
    func addCatchesToMap(catches: [Catch]) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            var catchPinColor: UIColor
            var origin: originType
            var pinID: String
            
            /* First remove any existing pins (except user location) so they don't get added again on top of old ones */
            self.mapView.annotations.forEach {
                if !($0 is MKUserLocation) {
                    self.mapView.removeAnnotation($0)
                }
            }
            
            for fish in catches {
                
                if fish.catchOrigin == "My Catches" {
                    origin = originType.MyCatch
                    catchPinColor = fish.pinColor()
                    pinID = self.myCatchPinID
                } else {
                    origin = originType.OtherCatch
                    catchPinColor = fish.pinColor()
                    pinID = self.otherCatchPinID
                }
                
                let annotation = CatchAnnotation(origin: origin , species: fish.species, weight: "\(fish.weightPounds) lbs \(fish.weightOunces) oz", lureTypeAndColor: "\(fish.baitType) \(fish.baitColor)", coordinate: fish.coordinate)
                
                /* Reuse annotatiovView if available */
                if let annotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier(pinID) {
                    annotationView.annotation = annotation
                    
                } else {
                    let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinID)
                
                    annotationView.pinTintColor = catchPinColor
                    annotationView.animatesDrop = true
                    annotationView.draggable = false
                }
                
                self.mapView.addAnnotation(annotation)
            
        }
            
        }
        
    }
    
    /* Method to display an alertView with a single OK button to acknowledge */
    func showAlertView(title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /* Method to query other user's catches from Firebase db and store them in Core Data */
    func getCatchesFromFirebase(completion: (success: Bool) -> Void) {
        
        firebaseRef.child("users").queryOrderedByChild("users").observeSingleEventOfType(.Value, withBlock: { firebaseSnapshot in
            
            if let catchDictionary = firebaseSnapshot.value as? NSDictionary {
                
                for (user, catches) in catchDictionary {
                    //Only get the catch data for the other users
                    if (user as! String) != self.userDeviceID {
                        
                        //Iterate over all of their catches
                        for fish in (catches as! NSDictionary) {
                            
                            let fishDictionary = (fish.value as! NSDictionary)
                            
                                //Create a new Catch Object in shared context from the retrieved dictionary
                            let _ = Catch(origin: otherCatchString, userDeviceID: user as! String, autoID: fish.key as! String, lat: fishDictionary["latitude"] as! Double, long: fishDictionary["longitude"] as! Double, species: fishDictionary["species"] as! String, weight: fishDictionary["weight"] as! Double, baitType: fishDictionary["baitType"] as! String, baitColor: fishDictionary["baitColor"] as! String, share: true, context: self.sharedContext)
                            
                                CoreDataStackManager.sharedInstance().saveContext()
                            
                        }
                        
                    }
                }
                
                completion(success: true)
                
            } else {
                completion(success: false)
            }
        })
        

    }
    
    
    //MARK: MapView Delegate Methods
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? CatchAnnotation {
            
            var pinID: String
            var view: MKPinAnnotationView
            
            if annotation.origin == originType.MyCatch { pinID = myCatchPinID }
            else { pinID = otherCatchPinID }
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(pinID) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
                
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinID)
                view.canShowCallout = true
                
                view.pinTintColor = annotation.pinColor()
                
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

