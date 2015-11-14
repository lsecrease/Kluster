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
}
