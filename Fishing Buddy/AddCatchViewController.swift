//
//  AddCatchViewController.swift
//  Fishing Buddy
//
//  Created by Ed Ballington on 4/3/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Firebase


class AddCatchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate {
    
    //MARK: Constants
    
    let speciesPickerValues = ["Largemouth Bass", "Smallmouth Bass", "Striped Bass", "Catfish", "Crappie", "Bluegill", "Walleye"]
    let lurePickerValues = ["Plastic Worm", "Plastic Lizard", "Fluke", "Crankbait", "Spinner Bait", "Jig", "Swimbait", "Buzzbait", "Artificial Frog", "Other"]
    let lureColorPickerValues = [["Black", "Blue", "Purple", "Chartreuse", "Pumpkin", "Watermelon", "Red", "Pink", "White", "Yellow", "Green"], ["Black", "Blue", "Purple", "Chartreuse", "Pumpkin", "Watermelon", "Red", "Pink", "White", "Yellow", "Green"]]
    let weightPickerValues = [["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25"], ["lbs"], ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"], ["oz"]]
    
    let firebaseRef = Firebase(url: "https://blistering-heat-7872.firebaseio.com/")
    
    enum pickerViewTag: Int {       //Used to identify the various picker views when calling the delegate and datasource methods
        case speciesPicker = 0
        case lurePicker = 1
        case lureColorPicker = 2
        case weightPicker = 3
    }
    
    
    //MARK: Properties
    
    var catchAnnotation = MKPointAnnotation()     //Annotation used for the mapView to locate the catch - there should be only on
    var weightDecimalValue: Double?             //Weight in lbs
    var locationManager = CLLocationManager()
    
    /* Devices Unique ID to distinguish this catch from other user's catches */
    var userDeviceID = UIDevice.currentDevice().identifierForVendor!.UUIDString
    

    
    //MARK: Outlets

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var speciesTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var lureTextField: UITextField!
    @IBOutlet weak var lureColorTextField: UITextField!
    @IBOutlet weak var shareCatchSwitch: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var pickerSelection = String()
    
    
    //MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        setupPickerViews()
        
        setMapInitialState()
        
    }
    
    //MARK: Actions
    
    @IBAction func saveCatch(sender: AnyObject) {
        
        //Check that mandatory fields are completed and display alertView for any that aren't
        
        guard (speciesTextField.text) != "" else {
            showAlertView("Please select a value for Species")
            return
        }
        
        guard (weightTextField.text) != "" else {
            showAlertView("Please select a value for the catch weight")
            return
        }
        
        guard (lureTextField.text) != "" else {
            showAlertView("Please select a value for the lure type")
            return
        }
        
        guard (lureColorTextField.text) != "" else {
            showAlertView("Please select values for the lure color")
            return
        }
        
        //Initialize a new Catch Object from the entered data
        let fish = Catch(lat: self.catchAnnotation.coordinate.latitude, long: self.catchAnnotation.coordinate.longitude, species: speciesTextField.text!, weight: weightDecimalValue!, baitType: lureTextField.text!, baitColor: lureColorTextField.text!, share: shareCatchSwitch.on, context: sharedContext)
    
        //Save Catch object to Core Data if everything OK
        CoreDataStackManager.sharedInstance().saveContext()
        
        //Save Catch object to Firebase db if 'Share' is enabled
        if fish.share {
            let userRef = firebaseRef.childByAppendingPath("users").childByAppendingPath(userDeviceID)
            let newCatchRef = userRef.childByAutoId()
            newCatchRef.setValue(fish.jsonDictionary)
        }
        
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    
    //MARK: Other methods
     
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pinAnnotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier("myPin") as? MKPinAnnotationView
        
        if pinAnnotationView == nil {
            let annotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            annotation.draggable = true
            annotation.animatesDrop = true
            return annotation

        }
        
        return pinAnnotationView
        
    }
    
    
    //MARK: Convenience methods
    
    //Setup initial map view by zooming in to current location
    func setMapInitialState() {
        
        mapView.showsUserLocation = false
        
        _ = locationManager.requestLocation()
        
        //Drop an initial pin for the catch location at the users current location - can be dragged to a new location afterwards
        catchAnnotation.coordinate = (locationManager.location?.coordinate)!
        mapView.addAnnotation(catchAnnotation)
        
    }
    
    /* Method to display an alertView with a single OK button to acknowledge */
    func showAlertView(message: String?) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /* Method to configure all of the Picker Views */
    func setupPickerViews() {
        
        /* Setup PickerView toolbars */
        let selectButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(AddCatchViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(AddCatchViewController.cancelPicker))
        
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.Default
        toolbar.translucent = true
        toolbar.tintColor = UIColor.blueColor()
        toolbar.sizeToFit()
        toolbar.setItems([cancelButton, spaceButton, selectButton], animated: false)
        toolbar.userInteractionEnabled = true
        
        /* Species Picker */
        let speciesPicker = UIPickerView()
        speciesPicker.tag = pickerViewTag.speciesPicker.rawValue
        speciesPicker.dataSource = self
        speciesPicker.delegate = self
        
        self.speciesTextField.inputView = speciesPicker
        self.speciesTextField.inputAccessoryView = toolbar
        
        /* Weight Picker */
        let weightPicker = UIPickerView()
        weightPicker.tag = pickerViewTag.weightPicker.rawValue
        weightPicker.dataSource = self
        weightPicker.delegate = self
        
        self.weightTextField.inputView = weightPicker
        self.weightTextField.inputAccessoryView = toolbar
        
        /* Lure Picker */
        let lurePicker = UIPickerView()
        lurePicker.tag = pickerViewTag.lurePicker.rawValue
        lurePicker.dataSource = self
        lurePicker.delegate = self
        
        self.lureTextField.inputView = lurePicker
        self.lureTextField.inputAccessoryView = toolbar

        /* Lure Color Picker */
        let lureColorPicker = UIPickerView()
        lureColorPicker.tag = pickerViewTag.lureColorPicker.rawValue
        lureColorPicker.dataSource = self
        lureColorPicker.delegate = self
        
        self.lureColorTextField.inputView = lureColorPicker
        self.lureColorTextField.inputAccessoryView = toolbar
        
    }
    
    func donePicker() {
        
        if speciesTextField.isFirstResponder() {
            speciesTextField.text = (pickerSelection != "") ? pickerSelection : speciesPickerValues[0]
            speciesTextField.resignFirstResponder()
        } else if lureTextField.isFirstResponder() {
            lureTextField.text = (pickerSelection != "") ? pickerSelection : lurePickerValues[0]
            lureTextField.resignFirstResponder()
        } else if weightTextField.isFirstResponder() {
            weightTextField.text = pickerSelection
            weightTextField.resignFirstResponder()
        } else if lureColorTextField.isFirstResponder() {
            lureColorTextField.text = pickerSelection
            lureColorTextField.resignFirstResponder()
        }
        
    }
    
    func cancelPicker() {
        
        if speciesTextField.isFirstResponder() {
            speciesTextField.resignFirstResponder()
        } else if lureTextField.isFirstResponder() {
            lureTextField.resignFirstResponder()
        } else if weightTextField.isFirstResponder() {
            weightTextField.resignFirstResponder()
        } else if lureColorTextField.isFirstResponder() {
            lureColorTextField.resignFirstResponder()
        }
    }
    
    
    //MARK: PickerView Datasource methods

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        switch pickerView.tag {
        case pickerViewTag.speciesPicker.rawValue:
            return speciesPickerValues.count
        case pickerViewTag.lurePicker.rawValue:
            return lurePickerValues.count
        case pickerViewTag.weightPicker.rawValue:
            return weightPickerValues[component].count
        case pickerViewTag.lureColorPicker.rawValue:
            return lureColorPickerValues[component].count
        default:
            return 1
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        switch pickerView.tag {
        case pickerViewTag.speciesPicker.rawValue:
            return 1
        case pickerViewTag.lurePicker.rawValue:
            return 1
        case pickerViewTag.weightPicker.rawValue:
            return 4
        case pickerViewTag.lureColorPicker.rawValue:
            return 2
        default:
            return 1
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView.tag {
        case pickerViewTag.speciesPicker.rawValue:
            return speciesPickerValues[row]
        case pickerViewTag.lurePicker.rawValue:
            return lurePickerValues[row]
        case pickerViewTag.weightPicker.rawValue:
            return weightPickerValues[component][row]
        case pickerViewTag.lureColorPicker.rawValue:
            return lureColorPickerValues[component][row]
        default:
            return nil
        }
        
    }
    
    
    //MARK: PickerView Delegate methods
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView.tag {
        case pickerViewTag.speciesPicker.rawValue:
            pickerSelection = speciesPickerValues[row]
        case pickerViewTag.lurePicker.rawValue:
            pickerSelection = lurePickerValues[row]
        case pickerViewTag.weightPicker.rawValue:
            pickerSelection = weightPickerValues[0][pickerView.selectedRowInComponent(0)] + " lbs " + weightPickerValues[2][pickerView.selectedRowInComponent(2)] + " oz"
            weightDecimalValue = Double(weightPickerValues[0][pickerView.selectedRowInComponent(0)])! + Double(weightPickerValues[2][pickerView.selectedRowInComponent(2)])!/16
        case pickerViewTag.lureColorPicker.rawValue:
            pickerSelection = lureColorPickerValues[0][pickerView.selectedRowInComponent(0)] + "/" + lureColorPickerValues[1][pickerView.selectedRowInComponent(1)]
        default:
            self.pickerSelection = "TEST"
        }

    }
    
    
    //MARK: Location Manager Delegate methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0]
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        let latDelta: CLLocationDegrees = 0.05
        let longDelta: CLLocationDegrees = 0.05
        let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        self.mapView.setRegion(region, animated: true)
        
        self.activityIndicator.stopAnimating()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        dispatch_async(dispatch_get_main_queue()) { 
            self.showAlertView("Can't determine current location - please make sure location services are enabled in settings")
        }
    }
    
    
    //MARK: - Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()

}
