//
//  ListViewController.swift
//  Fishing Buddy
//
//  Created by Ed Ballington on 3/29/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    //MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: Constants
    
    /* Devices Unique ID to distinguish my catches from other user's catches */
    let userDeviceID = UIDevice.currentDevice().identifierForVendor!.UUIDString
    
    
    //MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController.delegate = self
        
        //Set up Firebase connection state monitor
        let connectedRef = FIRDatabase.database().referenceWithPath(".info/connected")
        connectedRef.observeEventType(.Value, withBlock: {snapshot in
            
            let connected = snapshot.value as? Bool
            if connected != nil && connected! {
                self.showAlertView("Alert", message: "Connection to server restored - all pending catches will be updated")
                self.refreshCatches()
            } else {
                self.showAlertView("Alert", message: "Connection to server lost - catches by others may not be up to date")
            }
            
        })
        
        refreshCatches()

    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        
        tableView.reloadData()
    
    }
    
    
    //MARK: - Actions
   
    
    @IBAction func refreshTableView(sender: AnyObject) {
        
        refreshCatches()
        
        tableView.reloadData()
        
    }
    
    // MARK: - TableView Delegate & Datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if let sections  = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "CatchTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! CatchTableViewCell
        
        let fish = fetchedResultsController.objectAtIndexPath(indexPath) as! Catch
        cell.catchImage.image = UIImage(named: fish.species)
        cell.species.text = fish.species
        cell.weight.text = "\(fish.weightPounds) lbs \(fish.weightOunces) oz"
        cell.lureTypeAndColor.text = "\(fish.baitColor) \(fish.baitType)"
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.name
        }
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
        case .Delete:
            let fish = fetchedResultsController.objectAtIndexPath(indexPath) as! Catch
            
            //Delete object from fetched results controller
            self.sharedContext.deleteObject(fish)
            
            //Delete object from Firebase also
            firebaseRef.child("users").child(userDeviceID).child(fish.autoID).removeValue()
            
            do {
                try sharedContext.save()
            } catch let error as NSError {
                print("Error saving context after delete: \(error.localizedDescription)")
            }
            
            tableView.reloadData()
            
        default: break
        }
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        //If the section index is 1 - i.e. the "Other people's catches" section - then it should not be editable
        if (fetchedResultsController.objectAtIndexPath(indexPath) as! Catch).catchOrigin == otherCatchString {
            return false
        } else {
            return true
        }
        
    }
    
    
    // MARK: - Convenience Methods
    
    /* Method to display an alertView with a single OK button to acknowledge */
    func showAlertView(title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /* Retrieve all catches from FetchedResultsController */
    func fetchAllCatches() {
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            dispatch_async(dispatch_get_main_queue(), {
                self.showAlertView("Error", message: "Error retrieving catch data")
            })
        }
        
    }
    
    func refreshCatches() {
        
        /* Load catches from fetchedResultsController */
        
        fetchAllCatches()
        
        // Load catches from Core Data and
        if let catches = fetchedResultsController.fetchedObjects as? [Catch] {
            
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
        
        /* Third, fetch the newly updated data from fetchedResultsController so tableView will get updated */
        getCatchesFromFirebase({ (success) in
            
            self.fetchAllCatches()
            
        })
        
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


    
    // MARK: - Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Catch")
        
        fetchRequest.sortDescriptors = []
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: "catchOrigin",
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        tableView.beginUpdates()
        
    }
    
    //Perform an animated batch change of all of the updates after collecting the indexPaths into the appropriate arrays
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        tableView.endUpdates()
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        default:
            break
        }
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            if let indexPath  = newIndexPath {
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
            break;

        default:
            tableView.reloadData()
        }
        
    }

}

