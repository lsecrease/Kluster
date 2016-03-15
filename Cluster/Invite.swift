//
//  Invite.swift
//  Cluster
//
//  Created by Michael Fellows on 3/15/16.
//  Copyright © 2016 ImagineME. All rights reserved.
//

import Foundation

class Invite : NSObject {
    var fromUser: PFUser?
    var avatarFile: PFFile?
    var userName = ""
    var dateString = ""
    var accepted = false
    var kluster: Kluster?
    var declined = false
    var objectId = ""
    
    init(object: PFObject?) {
        guard let object = object else {
            return
        }
        
        guard let fromUser = object.objectForKey("fromUser") as? PFUser else {
            return
        }
        
        if let id = object.objectId {
            self.objectId = id
        }
        
        self.fromUser = fromUser
        if let file = fromUser.objectForKey("avatarThumbnail") as? PFFile {
            self.avatarFile = file
        }
        
        if let firstName = fromUser.objectForKey("firstName") as? String, let lastName = fromUser.objectForKey("lastName") as? String {
            self.userName = "\(firstName) \(lastName)"
        }
        
        if let k = object.objectForKey("kluster") as? PFObject {
            self.kluster = Kluster.init(object: k)
        }
        
        if let accepted = object.objectForKey("accepted") as? Bool {
            self.accepted = accepted
        }
    }
    
    func acceptKlusterInvite() {
        self.accepted = true
    }
    
    func declineInvite() {
        self.declined = true
    }
    
    func klusterInviteString() -> String {
        if let kluster = self.kluster {
            return "Invited you to join '\(kluster.title)'"
        } else {
            return "Invited you to a Kluster"
        }
    }
}