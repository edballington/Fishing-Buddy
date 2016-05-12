//
//  ListViewController.swift
//  Fishing Buddy
//
//  Created by Ed Ballington on 3/29/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    //MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            dispatch_async(dispatch_get_main_queue(), {
                self.showAlertView("Error retrieving catch data")
            })
        }
        
        tableView.reloadData()
    }
    
    
    //MARK: - Actions
   
    @IBAction func filterTableView(sender: AnyObject) {
    }
    
    @IBAction func refreshTableView(sender: AnyObject) {
        
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
        cell.lureTypeAndColor.text = "\(fish.baitColor!) \(fish.baitType!)"
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    
    // MARK: - Convenience Methods
    
    /* Method to display an alertView with a single OK button to acknowledge */
    func showAlertView(message: String?) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
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
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    /*
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        //Reset the arrays that track the indexPaths to handle the changes in content
        insertedIndexPaths.removeAll()
        deletedIndexPaths.removeAll()
        updatedIndexPaths.removeAll()
        
    }
    
    //Handle the various change types every time a collection view cell makes a change
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            updatedIndexPaths.append(indexPath!)
            break
        default:
            return
            
        }
        
    }
    
    
    //Perform an animated batch change of all of the updates after collecting the indexPaths into the appropriate arrays
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        //Enable bottom button if there are any pictures
        if controller.fetchedObjects?.count > 0 {
            bottomButton.enabled = true
        }
        
        collectionView.performBatchUpdates({ () -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
        
    }
*/
}

