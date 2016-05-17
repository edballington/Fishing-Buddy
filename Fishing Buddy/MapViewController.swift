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

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate {

    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    //MARK: Properties
    var mapCenterLocation: CLLocationCoordinate2D?
    
    /* Devices Unique ID to distinguish my catches from other user's catches */
    var userDeviceID = UIDevice.currentDevice().identifierForVendor!.UUIDString
    
    
    //MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        setMapInitialState()
    
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //If a center coordinate has been set then change to it - otherwise leave map as is
        if let mapCoordinate = mapCenterLocation {
            self.mapView.setCenterCoordinate(mapCoordinate, animated: true)
        }
        
        // Load catches from Fetched Results Controller and add to map if there are any
        if let catches = fetchAllCatches() {
            addCatchesToMap(catches)
        }
        
    }


    //MARK: Convenience Methods
    func setMapInitialState() {
        
        mapView.showsUserLocation = true
        //self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        
    }
    
    /* Retrieves all Catch objects from Fetched Results Controller */
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
    
    /* Add Catches to mapView from array */
    func addCatchesToMap(catches: [Catch]) {
        
        for fish in catches {
            
            let annotation = CatchAnnotation(species: fish.species, weight: "\(fish.weightPounds) lbs \(fish.weightOunces) oz", lureTypeAndColor: "\(fish.baitType) \(fish.baitColor)", coordinate: fish.coordinate)
            
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

