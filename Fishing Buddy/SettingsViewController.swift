//
//  SettingsViewController.swift
//  Fishing Buddy
//
//  Created by Ed Ballington on 5/10/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var showUserLocationSwitch: UISwitch!
    @IBOutlet weak var myCatchPinColorControl: UISegmentedControl!
    @IBOutlet weak var otherCatchPinColorControl: UISegmentedControl!
    
    
    //MARK: - Properties
    
    var defaults = NSUserDefaults.standardUserDefaults()
    
    
    //MARK: - View Controller Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        
        showUserLocationSwitch.setOn(defaults.boolForKey(USER_LOCATION_SWITCH_KEY), animated: false)
        
        myCatchPinColorControl.selectedSegmentIndex = defaults.integerForKey(MY_CATCH_PIN_COLOR_KEY)
        otherCatchPinColorControl.selectedSegmentIndex = defaults.integerForKey(OTHER_CATCH_PIN_COLOR_KEY)
        
    }
    
    @IBAction func displayUserLocSwitchChanged(sender: AnyObject) {
        
        defaults.setBool(showUserLocationSwitch.on, forKey: USER_LOCATION_SWITCH_KEY)
        
    }
    
    @IBAction func myCatchIndexChanged(sender: AnyObject) {
        
        defaults.setInteger(myCatchPinColorControl.selectedSegmentIndex, forKey: MY_CATCH_PIN_COLOR_KEY)
        
    }
    
    @IBAction func otherCatchIndexChanged(sender: AnyObject) {
        
        defaults.setInteger(otherCatchPinColorControl.selectedSegmentIndex, forKey: OTHER_CATCH_PIN_COLOR_KEY)
        
    }


}
