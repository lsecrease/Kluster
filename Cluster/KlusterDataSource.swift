//
//  KlusterDataSource.swift
//  Cluster
//
//  Created by Michael Fellows on 11/13/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import Foundation

class KlusterDataSource: NSObject {
    class func createKlusterWithParams(params: Dictionary<String, String>, completion:PFIdResultBlock) -> Void
    {
        PFCloud.callFunctionInBackground("createKluster", withParameters: params) {
            (object, error) in
            completion(object, error)
        }
    }
    
    class func searchForKlusterWithString(searchString: String, completion:PFIdResultBlock) -> Void
    {
        PFCloud.callFunctionInBackground("searchForKluster", withParameters: ["searchString": searchString]) { (object, error) -> Void in
            completion(object, error)
        }
    }
    
    class func fetchKlustersForUser(completion:PFIdResultBlock) -> Void {
        PFCloud.callFunctionInBackground("fetchKlustersForUser", withParameters: nil) { (object, error) -> Void in
            completion(object, error)
        }
    }
    
    class func fetchMembersForKluster(kluster: Kluster!, completion:PFArrayResultBlock) -> Void {
        let query = kluster.memberRelation.query()
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            completion(objects, error)
        }
    }
}
