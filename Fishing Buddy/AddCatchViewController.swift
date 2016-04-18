//
//  AddCatchViewController.swift
//  Fishing Buddy
//
//  Created by Ed Ballington on 4/3/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//

import UIKit
import MapKit

class AddCatchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, MKMapViewDelegate {
    
    //MARK: Constants
    
    let speciesPickerValues = ["Largemouth Bass", "Smallmouth Bass", "Striped Bass", "Bream", "Catfish", "Crappie", "Bluegill", "Walleye"]
    let lurePickerValues = ["Plastic Worm", "Crankbait", "Spinner Bait", "Jig", "Plastic Frog", "Live Minnow", "Live Worm", "Live Cricket", "Other"]
    let lureColorPickerValues = [["Green", "Blue", "Red", "Orange", "Yellow", "Pink", "Black"],["Green", "Blue", "Red", "Orange", "Yellow", "Pink", "Black"]]
    let weightPickerValues = [["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25"], ["lbs"], ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"], ["oz"]]
    
    enum pickerViewTag: Int {       //Used to identify the various picker views when calling the delegate and datasource methods
        case speciesPicker = 0
        case lurePicker = 1
        case lureColorPicker = 2
        case weightPicker = 3
    }
    
    
    //MARK: Properties
    
    var catchAnnotation: MKPointAnnotation?     //Annotation used for the mapView to locate the catch - there should be only one
    var catchAnnotationView = MKPinAnnotationView()

    
    //MARK: Outlets

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var speciesTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var lureTextField: UITextField!
    @IBOutlet weak var lureColorTextField: UITextField!
    @IBOutlet weak var shareCatchSwitch: UISwitch!
    
    
    var pickerSelection = String()
    
    
    //MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPickerViews()
        
        //Add a gesture recognizer for long press to add pins
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(AddCatchViewController.dropPin(_:)))
        longPressRecognizer.minimumPressDuration = 0.6
        mapView.addGestureRecognizer(longPressRecognizer)
        
        mapView.delegate = self
        
    }
    
    //MARK: Actions
    
    @IBAction func saveCatch(sender: AnyObject) {
        
        //TODO: - Check that mandatory fields are completed
        
        //TODO: - Display alertView for any that aren't and leave view up
        
        //TODO: - Save Catch object to Core Data if everything OK
        
        //TODO: - Test
        
    }
    
    
    //MARK: Other methods
    
    func dropPin(sender: UIGestureRecognizer) {
        
        if sender.state != UIGestureRecognizerState.Began {
            return
        }
        
        let pinCoordinate = mapView.convertPoint(sender.locationInView(mapView), toCoordinateFromView: mapView)
        
            catchAnnotation = MKPointAnnotation()
            catchAnnotation!.coordinate = pinCoordinate
        
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.mapView.addAnnotation(self.catchAnnotation!)
            }
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinAnnotationView = MKPinAnnotationView()
        
        if let pinAnnotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier("myPin") {
            print("Reusing annotationView")
            pinAnnotationView.annotation = annotation
            pinAnnotationView.draggable = true

        } else {
            print("Creating a new annotationView")
            pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
        
                pinAnnotationView.draggable = true
                pinAnnotationView.canShowCallout = true
                pinAnnotationView.animatesDrop = true
            
        }
        
            return pinAnnotationView
        
    }
    
    //Handle dragging of annotation
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        print("didChangeDragState")
        switch (newState) {
        case .Starting:
            print("Starting DragState")
            view.dragState = .Dragging
        case .Ending, .Canceling:
            print("Ending or Cancelling DragState")
            view.dragState = .None
        default:
            break
        }
    }
    
    
    //MARK: Convenience methods
    
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
            speciesTextField.text = pickerSelection
            speciesTextField.resignFirstResponder()
        } else if lureTextField.isFirstResponder() {
            lureTextField.text = pickerSelection
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
        case pickerViewTag.lureColorPicker.rawValue:
            pickerSelection = lureColorPickerValues[0][pickerView.selectedRowInComponent(0)] + " / " + lureColorPickerValues[1][pickerView.selectedRowInComponent(1)]
        default:
            self.pickerSelection = "TEST"
        }

    }

}
