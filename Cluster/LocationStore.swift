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
    
    func updateLocation(_ latitude: Double!, longitude: Double!) {
        UserDefaults.standard.set(latitude, forKey: self.latitudeKey)
        UserDefaults.standard.set(longitude, forKey: self.longitudeKey)
    }
    
    func currentLatitude() -> Double {
        return UserDefaults.standard.double(forKey: self.latitudeKey)
    }
    
    func currentLongitude() -> Double {
        return UserDefaults.standard.double(forKey: self.longitudeKey)
    }
}
