//
//  LocationStore.swift
//  Cluster
//
//  Created by Michael Fellows on 3/9/16.
//  Copyright © 2016 ImagineME. All rights reserved.
//

import Foundation

class LocationStore : NSObject {
    let latitudeKey = "keyCurrentLatitiude"
    let longitudeKey = "keyCurrentLongitude"
    static let sharedStore = LocationStore()
    
    func updateLocation(latitude: Double!, longitude: Double!) {
        NSUserDefaults.standardUserDefaults().setDouble(latitude, forKey: self.latitudeKey)
        NSUserDefaults.standardUserDefaults().setDouble(longitude, forKey: self.longitudeKey)
    }
    
    func currentLatitude() -> Double {
        return NSUserDefaults.standardUserDefaults().doubleForKey(self.latitudeKey)
    }
    
    func currentLongitude() -> Double {
        return NSUserDefaults.standardUserDefaults().doubleForKey(self.longitudeKey)
    }
}
