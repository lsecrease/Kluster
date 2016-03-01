//
//  KlusterStore.swift
//  Cluster
//
//  Created by Michael Fellows on 3/1/16.
//  Copyright © 2016 ImagineME. All rights reserved.
//

import Foundation

class KlusterStore: NSObject {
    var userKlusters: [PFObject]? = [PFObject]()
    static let sharedInstance = KlusterStore()
    
    internal func userIsMemberOfKluster(klusterId: String!) -> Bool {
        for kluster in self.userKlusters! {
            if (kluster.objectId == klusterId) {
                return true
            }
        }
        
        return false
    }
}
