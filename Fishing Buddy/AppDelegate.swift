//
//  AppDelegate.swift
//  Fishing Buddy
//
//  Created by Ed Ballington on 3/29/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //Register default settings values for the first time app is launched before they are set by the user
        
        let defaults: [String:AnyObject] = [
            USER_LOCATION_SWITCH_KEY: true,
            MY_CATCH_PIN_COLOR_KEY: 0,
            OTHER_CATCH_PIN_COLOR_KEY: 2
        ]
        NSUserDefaults.standardUserDefaults().registerDefaults(defaults)
        
        //Configure FIRApp shared instance for Firebase
        FIRApp.configure()
        
        //Enable disk persistence via Firebase
        FIRDatabase.database().persistenceEnabled = true
        
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

