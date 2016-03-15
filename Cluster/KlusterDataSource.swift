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
    
    class func joinKluster(klusterId: NSString!, completion:PFIdResultBlock) -> Void {
        let params = ["klusterId": klusterId]
         PFCloud.callFunctionInBackground("joinKluster", withParameters: params) { (object, error) -> Void in
            completion(object, error)
        }
    }
    
    class func searchForKlusterWithString(searchString: String, completion:PFIdResultBlock) -> Void
    {
        let lowercaseString = searchString.lowercaseString
        PFCloud.callFunctionInBackground("searchForKluster", withParameters: ["searchString": lowercaseString]) { (object, error) -> Void in
            completion(object, error)
        }
    }
    
    class func fetchMainKlusters(params: [NSObject : AnyObject]?, completion: PFIdResultBlock) -> Void {
        PFCloud.callFunctionInBackground("fetchMainKlusters", withParameters: params) { (object, error) -> Void in
            KlusterStore.sharedInstance.userKlusters = object as? [PFObject]
            completion(object, error)
        }
    }
    
    class func deleteKluster(klusterId: String, completion: PFIdResultBlock) -> Void {
        PFCloud.callFunctionInBackground("deleteKluster", withParameters: ["klusterId": klusterId]) { (object, error) -> Void in
            completion(object, error)
        }
    }
    
    class func fetchKlustersForUser(completion:PFIdResultBlock) -> Void {
        PFCloud.callFunctionInBackground("fetchKlustersForUser", withParameters: nil) { (object, error) -> Void in
            KlusterStore.sharedInstance.userKlusters = object as? [PFObject]
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
    
    // Delete user account
    class func deleteUserAccount(completion: PFIdResultBlock) -> Void {
        PFCloud.callFunctionInBackground("deleteUserAccount", withParameters: nil) { (object, error) -> Void in
            completion(object, error)
        }
    }
    
    class func fetchUsersWithFacebookIds(facebookIDs: [String], kluster: Kluster,completion: PFIdResultBlock) -> Void {
        if let query = PFUser.query() {
            query.whereKey("facebookId", containedIn: facebookIDs)
            
            // Important to not show Kluster members in the Facebook query. They're already members 😉
//            let memberRelation = kluster.memberRelation.query()
//            query.whereKey("objectId", doesNotMatchQuery: memberRelation)
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                completion(objects, error)
            })
        }
    }
}
