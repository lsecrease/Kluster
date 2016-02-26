//
//  HomeViewController.swift
//  Cluster
//
//  Created by lsecrease on 8/19/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var backgroundImageView:UIImageView!
    @IBOutlet weak var collectionView:UICollectionView!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var currentUserProfileImageButton:UIButton!
    @IBOutlet weak var currentUserFullNameButton:UIButton!
    @IBOutlet weak var profileAvatar: PFImageView!
    @IBOutlet var createKlusterButton: UIButton!
    
    //MARK: - UICollectionViewDataSource
    private var klusters = [PFObject]()
    var locationManager = CLLocationManager()
    var currentGeoPoint: PFGeoPoint?
    
    //MARK: - Change Status Bar to White
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        
        // Update the user profile information
        let user = PFUser.currentUser()
        self.profileAvatar.file = user?.objectForKey("avatarThumbnail") as? PFFile
        self.profileAvatar.loadInBackground()
        
        let firstName = user?.objectForKey("firstName") as? String
        self.currentUserFullNameButton.setTitle(firstName, forState: .Normal)
        
        profileAvatar.layer.cornerRadius = 10.0
        profileAvatar.clipsToBounds = true
        
        //Side Menu
        if self.revealViewController() != nil {
            menuButton.addTarget(self.revealViewController(), action: "revealToggle:", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.calculateCurrentLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.fetchKlusters()
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        let locationAuthorized = authorizationStatus == .AuthorizedWhenInUse
        self.createKlusterButton.enabled = locationAuthorized
        if (locationAuthorized) {
            self.locationManager.startUpdatingLocation()
        } else {
            // let's request location authorization
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func showLogin() {
        let storyboard = UIStoryboard.init(name: "Login", bundle: nil)
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.presentViewController(loginVC, animated: true, completion: nil)
    }
    
    private func calculateCurrentLocation() {
        PFGeoPoint.geoPointForCurrentLocationInBackground({ (geoPoint, error) -> Void in
            if (error == nil) {
                self.currentGeoPoint = geoPoint
            }
        })
    }
    
    @IBAction func searchButtonPressed(sender: AnyObject) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let searchController = storyboard.instantiateViewControllerWithIdentifier("KlusterSearchController") as! KlusterSearchController
        let navigationController = UINavigationController.init(rootViewController: searchController)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    private func fetchKlusters() {
        
        // This is incredibly gross and should be refactored
        if (self.currentGeoPoint != nil) {
            let params = ["latitude" : self.currentGeoPoint!.latitude,
                "longitude" : self.currentGeoPoint!.longitude]
            
            KlusterDataSource.fetchMainKlusters(params as [NSObject : AnyObject]) { (objects, error) -> Void in
                if (error != nil) {
                    print("Error: %@", error?.localizedDescription)
                } else {
                    self.klusters = objects as! [PFObject]
                    self.collectionView.reloadData()
                }
            }
        } else {
            KlusterDataSource.fetchMainKlusters(nil) { (objects, error) -> Void in
                if (error != nil) {
                    print("Error: %@", error?.localizedDescription)
                } else {
                    self.klusters = objects as! [PFObject]
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

extension HomeViewController : UICollectionViewDataSource
{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.klusters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = "Kluster Cell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! KlusterCollectionViewCell
        
        let user = PFUser.currentUser()
        let k = Kluster.init(object: self.klusters[indexPath.item])
        cell.kluster = k
        cell.joinKlusterButton.tag = indexPath.row
        cell.joinKlusterButton.addTarget(self, action: "joinKluster:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.joinKlusterButton.hidden = k.isCreator(user)
        
        cell.distanceLabel.text = k.distanceToKluster(self.currentGeoPoint)
        
        // Moved the PFImageView loading out of the cell
        cell.featuredImageView.tag = indexPath.row
        cell.featuredImageView.image = nil
        cell.featuredImageView.file = k.featuredImageFile
        cell.featuredImageView.loadInBackground { (image, error) -> Void in
            if (error != nil) {
                print("Error loading image...")
            } else {
                print("Finished loading image...")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.featuredImageView.image = image
                });
            }
        }
        
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: "featuredImageViewTapped:")
        cell.featuredImageView.addGestureRecognizer(tapRecognizer)
        
        return cell
    }
    
    func featuredImageViewTapped(sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let klusterVC = storyboard.instantiateViewControllerWithIdentifier("KlusterViewController") as! KlusterViewController;
        let k = Kluster.init(object: self.klusters[(sender.view?.tag)!])
    klusterVC.kluster = k
        
        // Show kluster
        let navigationController = UINavigationController.init(rootViewController: klusterVC)
        self.presentViewController(navigationController, animated: true, completion: nil);
    }
    
    func joinKluster(sender: UIButton) {
        // let k = self.klusters[sender.tag] as? Kluster
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let klusterVC = storyboard.instantiateViewControllerWithIdentifier("KlusterViewController") as! KlusterViewController;

        // Show kluster
        let navigationController = UINavigationController.init(rootViewController: klusterVC)
        self.presentViewController(navigationController, animated: true, completion: nil);
    }
}

extension HomeViewController : CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == .AuthorizedWhenInUse) {
            self.calculateCurrentLocation()
        }
    }
}

//MARK: - Scrolling Experience
extension HomeViewController : UIScrollViewDelegate
{
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.memory
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.memory = offset
        
    }
}


