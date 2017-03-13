//
//  Message.swift
//  Cluster
//
//  Created by Michael Fellows on 2/24/16.
//  Copyright © 2016 ImagineME. All rights reserved.
//

import Foundation

class Message: NSObject {
    var user: PFUser!
    var text: String?
    
    init(object: PFObject) {
        self.text = object.object(forKey: "text") as? String
        self.user = object.object(forKey: "sender") as! PFUser
    }
}
