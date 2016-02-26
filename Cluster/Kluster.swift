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
    var memberRelation: PFRelation!
    var creator: PFUser?

//    init(id: String, title: String, description: String, distance: String, featuredImage: UIImage!)
    init(object: PFObject!) {
        self.id = object.objectId!
        self.title = object.objectForKey("title") as! String
        self.summary = object.objectForKey("summary") as? String
        self.plans = object.objectForKey("plans") as? String
        self.location = object.objectForKey("location") as? PFGeoPoint
        self.featuredImageFile = object.objectForKey("photo") as! PFFile
        self.numberOfMembers = object.objectForKey("memberCount") as! Int
        self.memberRelation = object.relationForKey("members")
        self.creator = object.objectForKey("creatorId") as? PFUser
        
        // TODO: Calculate distance string
    }
    
    internal func isCreator(user: PFUser!) -> Bool {
        return user.objectId == self.creator?.objectId
    }
    
    internal func distanceToKluster(point: PFGeoPoint?) -> String {
        if (point == nil) {
            return ""
        }
        
        return String(format: "%.0fmi", point!.distanceInMilesTo(self.location))
    }
}