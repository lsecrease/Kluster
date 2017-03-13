//
//  Kluster.swift
//  Cluster
//
//  Created by lsecrease on 9/12/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import Foundation


class Kluster
{
    // MARK: - Public API
    var id = ""
    var title = ""
    var summary: String?
    var plans: String?
    var location: PFGeoPoint?
    var numberOfMembers = 0
    // var numberOfPosts = 0
    var featuredImageFile: PFFile!
    var distanceString = ""
    var memberRelation: PFRelation<PFObject>!
    var creator: PFUser?

//    init(id: String, title: String, description: String, distance: String, featuredImage: UIImage!)
    init(object: PFObject!) {
        self.id = object.objectId!
        self.title = object.object(forKey: "title") as! String
        self.summary = object.object(forKey: "summary") as? String
        self.plans = object.object(forKey: "plans") as? String
        self.location = object.object(forKey: "location") as? PFGeoPoint
        self.featuredImageFile = object.object(forKey: "photo") as! PFFile
        self.numberOfMembers = object.object(forKey: "memberCount") as! Int
        self.memberRelation = object.relation(forKey: "members")
        self.creator = object.object(forKey: "creatorId") as? PFUser
        
        // TODO: Calculate distance string
    }
    
    internal func isCreator(_ user: PFUser!) -> Bool {
        return user.objectId == self.creator?.objectId
    }
    
    internal func distanceToKluster(_ point: PFGeoPoint?) -> String {
        if (point == nil) {
            return ""
        }
        
        return String(format: "%.0fmi", point!.distanceInMiles(to: self.location))
    }
    
    internal func memberString() -> String {
        if (self.numberOfMembers == 1) {
            return "1 member"
        } else {
            return "\(self.numberOfMembers) members"
        }
    }
    
    internal func creatorString(_ user: PFUser!) -> String {
        if (user.objectId == self.creator?.objectId) {
            return "Creator"
        } else {
            return "Member"
        }
    }
}
