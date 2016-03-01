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
    
    public var completion: (PFGeoPoint? -> ())? 
    private var geoPoint: PFGeoPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        let gestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: "mapPressed:")
        gestureRecognizer.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    func mapPressed(sender: UILongPressGestureRecognizer) {
        if (sender.state == .Began) {
            let touchPoint = sender.locationInView(self.mapView)
            let touchCoordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            let point = MKPointAnnotation()
            point.coordinate = touchCoordinate
            point.title = "Kluster Location"
            for annotation in self.mapView.annotations {
                self.mapView.removeAnnotation(annotation)
            }
            
            self.mapView.addAnnotation(point)
            self.navigationItem.rightBarButtonItem?.enabled = true
            self.geoPoint = PFGeoPoint.init(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
        }
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        completion!(self.geoPoint)
    }
}