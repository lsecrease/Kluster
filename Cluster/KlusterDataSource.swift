//
//  KlusterDataSource.swift
//  Cluster
//
//  Created by Michael Fellows on 11/13/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import Foundation

class KlusterDataSource: NSObject {
    class func createKlusterWithParams(params: [NSObject : AnyObject]?, completion:PFIdResultBlock) -> Void
    {
        PFCloud.callFunctionInBackground("createKluster", withParameters: params) { (object, error) -> Void in
            completion(object, error)
        }
    }
    
    class func searchForKlusterWithString(searchString: String, completion:PFIdResultBlock) -> Void
    {
        PFCloud.callFunctionInBackground("searchForKluster", withParameters: ["searchString": searchString]) { (object, error) -> Void in
            completion(object, error)
        }
    }
    
    class func fetchMainKlusters(params: [NSObject : AnyObject]?, completion: PFIdResultBlock) -> Void {
        PFCloud.callFunctionInBackground("fetchMainKlusters", withParameters: params) { (object, error) -> Void in
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
    
    // Mark: - Sending messages
    class func createMessageInKluster(klusterId: String, text: String, completion: PFIdResultBlock) -> Void {
        let params = ["klusterId" : klusterId, "text": text]
        PFCloud.callFunctionInBackground("createMessage", withParameters: params) { (object, error) -> Void in
            completion(object, error)
        }
    }
    
    class func fetchMessagesInKluster(klusterId: String, skip: Int, completion: PFIdResultBlock) -> Void {
        let params = ["klusterId" : klusterId]
        PFCloud.callFunctionInBackground("fetchMessagesForKluster", withParameters: params) { (objects, error) -> Void in
            completion(objects, error)
        }
    }
}
