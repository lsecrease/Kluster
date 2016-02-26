//
//  LocationSelectViewController.swift
//  Cluster
//
//  Created by Michael Fellows on 2/25/16.
//  Copyright © 2016 ImagineME. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class LocationSelectViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    public var completion: (Int? -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        
    }
}