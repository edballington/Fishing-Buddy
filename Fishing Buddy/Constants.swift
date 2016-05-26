//
//  Constants.swift
//  Fishing Buddy
//
//  Created by Ed Ballington on 5/25/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//

import Foundation
import Firebase

enum originType {
    case MyCatch
    case OtherCatch
}

let USER_LOCATION_SWITCH_KEY = "enableUserLocation"
let MY_CATCH_PIN_COLOR_KEY = "myCatchPinColor"
let OTHER_CATCH_PIN_COLOR_KEY = "otherCatchPinColor"

let firebaseRef = Firebase(url: "https://blistering-heat-7872.firebaseio.com/")
