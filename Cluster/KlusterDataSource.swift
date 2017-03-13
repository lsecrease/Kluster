//
//  KlusterDataSource.swift
//  Cluster
//
//  Created by Michael Fellows on 11/13/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import Foundation

class KlusterDataSource: NSObject {
    
    class func createKlusterWithParams(_ params: [AnyHashable: Any]?, completion:@escaping PFIdResultBlock) -> Void
    {
        PFCloud.callFunction(inBackground: "createKluster", withParameters: params) { (object, error) -> Void in
            completion(object, error)
        }
    }
    
    class func joinKluster(_ klusterId: NSString!, completion:@escaping PFIdResultBlock) -> Void {
        let params = ["klusterId": klusterId]
         PFCloud.callFunction(inBackground: "joinKluster", withParameters: params) { (object, error) -> Void in
            completion(object, error)
        }
    }
    
    class func searchForKlusterWithString(_ searchString: String, completion:@escaping PFIdResultBlock) -> Void
    {
        let lowercaseString = searchString.lowercased()
        PFCloud.callFunction(inBackground: "searchForKluster", withParameters: ["searchString": lowercaseString]) { (object, error) -> Void in
            completion(object, error)
        }
    }
    
    class func fetchMainKlusters(_ params: [AnyHashable: Any]?, completion: @escaping PFIdResultBlock) -> Void {
        PFCloud.callFunction(inBackground: "fetchMainKlusters", withParameters: params) { (object, error) -> Void in
            KlusterStore.sharedInstance.userKlusters = object as? [PFObject]
            completion(object, error)
        }
    }
    
    class func deleteKluster(_ klusterId: String, completion: @escaping PFIdResultBlock) -> Void {
        PFCloud.callFunction(inBackground: "deleteKluster", withParameters: ["klusterId": klusterId]) { (object, error) -> Void in
            completion(object, error)
        }
    }
    
    class func fetchKlustersForUser(_ completion:@escaping PFIdResultBlock) -> Void {
        PFCloud.callFunction(inBackground: "fetchKlustersForUser", withParameters: nil) { (object, error) -> Void in
            KlusterStore.sharedInstance.userKlusters = object as? [PFObject]
            completion(object, error)
        }
    }
    
    class func fetchMembersForKluster(_ kluster: Kluster!, completion:@escaping PFArrayResultBlock) -> Void {
        let query = kluster.memberRelation.query()
        query.findObjectsInBackground { (objects, error) -> Void in
            completion(objects, error)
        }
    }
    
    // Mark: - Sending messages
    class func createMessageInKluster(_ klusterId: String, text: String, completion: @escaping PFIdResultBlock) -> Void {
        let params = ["klusterId" : klusterId, "text": text]
        PFCloud.callFunction(inBackground: "createMessage", withParameters: params) { (object, error) -> Void in
            completion(object, error)
        }
    }
    
    class func fetchMessagesInKluster(_ klusterId: String, skip: Int, completion: @escaping PFIdResultBlock) -> Void {
        let params = ["klusterId" : klusterId]
        PFCloud.callFunction(inBackground: "fetchMessagesForKluster", withParameters: params) { (objects, error) -> Void in
            completion(objects, error)
        }
    }
    
    // Delete user account
    class func deleteUserAccount(_ completion: @escaping PFIdResultBlock) -> Void {
        PFCloud.callFunction(inBackground: "deleteUserAccount", withParameters: nil) { (object, error) -> Void in
            completion(object, error)
        }
    }
    
    class func fetchUsersWithFacebookIds(_ facebookIDs: [String], kluster: Kluster,completion: @escaping PFIdResultBlock) -> Void {
        if let query = PFUser.query() {
            query.whereKey("facebookId", containedIn: facebookIDs)
            
            // Important to not show Kluster members in the Facebook query. They're already members 😉
//            let memberRelation = kluster.memberRelation.query()
//            query.whereKey("objectId", doesNotMatchQuery: memberRelation)
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                completion(objects, error)
            })
        }
    }
    
    // Takes an array of user ids and invites user to the specified kluster
    class func inviteUsersToKluster(_ userIds: [String]?, klusterId: String?,completion: @escaping PFIdResultBlock) -> Void {
        if let userIds = userIds, let klusterId = klusterId, userIds.count > 0 && klusterId.length > 0 {
            let params = ["klusterId": klusterId, "userIds": userIds] as [String : Any]
            PFCloud.callFunction(inBackground: "inviteUsersToKluster", withParameters: params as [AnyHashable: Any]) { (object, error) -> Void in
                completion(object, error)
            }
        }
    }
    
    class func fetchInvites(_ completion: @escaping PFIdResultBlock) -> Void {
        PFCloud.callFunction(inBackground: "fetchInvitationsForUser", withParameters: nil) { (object, error) -> Void in
            completion(object, error)
        }
    }
    
    // Accepts an invitation to a Kluster
    class func acceptInvitation(_ klusterId: String?, invitationId: String?, completion: @escaping PFIdResultBlock) -> Void {
        if let klusterId = klusterId, let invitationId = invitationId {
            let params = ["klusterId": klusterId, "invitationId": invitationId]
            PFCloud.callFunction(inBackground: "acceptInvitationToKluster", withParameters: params, block: { (object, error) -> Void in
                completion(object, error)
            })
        }
    }
    
    // Declines an invitation to a Kluster
    class func declineKlusterInvitation(_ invitationId: String?, completion: @escaping PFIdResultBlock) -> Void {
        if let invitationId = invitationId {
            let params = ["invitationId": invitationId]
            PFCloud.callFunction(inBackground: "declineKlusterInvitationToKluster", withParameters: params, block: { (object, error) -> Void in
                completion(object, error)
            })
        }
    }
}
