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


// MARK: - LocationSelectViewController

class LocationSelectViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet var mapView: MKMapView!
    
    // MARK: Properties
    
    open var completion: ((PFGeoPoint?) -> ())? 
    fileprivate var geoPoint: PFGeoPoint?
    
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        let gestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(LocationSelectViewController.mapPressed(_:)))
        gestureRecognizer.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    // MARK: UI functions
    
    func mapPressed(_ sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            let touchPoint = sender.location(in: self.mapView)
            let touchCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            let point = MKPointAnnotation()
            point.coordinate = touchCoordinate
            point.title = "Kluster Location"
            for annotation in self.mapView.annotations {
                self.mapView.removeAnnotation(annotation)
            }
            
            self.mapView.addAnnotation(point)
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.geoPoint = PFGeoPoint.init(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
        }
    }
    
    // MARK: IBActions
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        completion!(self.geoPoint)
        
//        if self.geoPoint == nil {
//            return
//        } else {
//            self.dismiss(animated: true, completion: nil)
//        }
    }
}
