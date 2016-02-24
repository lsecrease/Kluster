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
        // TODO: Calculate distance string
    }
    
    // MARK: - Private
//    
//    static func createKlusters() -> [Kluster]
//    {
//        return [
//            Kluster(id: "r1", title: "Miami Clique", description: "We love backpack and adventures! We walked to Antartica yesterday, and camped with so me cute pinguines, and talked about this wonderful app idea. 🐧⛺️✨", distance: "7 miles", featuredImage: UIImage(named: "1")!),
//            Kluster(id: "r2", title: "Romance Novels", description: "We love romantic stories. We walked to Antartica yesterday, and camped with some cute pinguines, and talked about this wonderful app idea. 🐧⛺️✨", distance: "9 miles", featuredImage: UIImage(named: "2")!),
//            Kluster(id: "r3", title: "iOS Dev", description: "Create beautiful apps. We walked to Antartica yesterday, and camped with some cute pinguines, and talked about this wonderful app idea. 🐧⛺️✨", distance: "10 miles", featuredImage: UIImage(named: "3")!),
//            Kluster(id: "r4", title: "Race", description: "Cars and aircrafts and boats and sky. We walked to Antartica yesterday, and camped with some cute pinguines, and talked about this wonderful app idea. 🐧⛺️✨", distance: "11 miles",featuredImage: UIImage(named: "5")!),
//            Kluster(id: "r5", title: "Personal Development", description: "Meet life with full presence. We walked to Antartica yesterday, and camped with some cute pinguines, and talked about this wonderful app idea. 🐧⛺️✨", distance: "12 miles",featuredImage: UIImage(named: "1")!),
//            Kluster(id: "r6", title: "Reading News", description: "Get up to date with breaking-news. We walked to Antartica yesterday, and camped with some cute pinguines, and talked about this wonderful app idea. 🐧⛺️✨", distance: "15 miles",featuredImage: UIImage(named: "2")!),
//        ]
//    }
}