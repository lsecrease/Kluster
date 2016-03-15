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
    @IBOutlet weak var backgroundImageView:PFImageView!
    @IBOutlet weak var collectionView:UICollectionView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var klusterTitle: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var currentUserProfileImageButton:UIButton!
    @IBOutlet var createKlusterButton: UIButton!
    
    //MARK: - UICollectionViewDataSource
    private var klusters = [PFObject]()
    var locationManager = CLLocationManager()
    var currentGeoPoint: PFGeoPoint?
    var userProfileView: ProfileNameView?
    
    //MARK: - Change Status Bar to White
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let latitude = LocationStore.sharedStore.currentLatitude()
        let longitude = LocationStore.sharedStore.currentLongitude()
        self.currentGeoPoint = PFGeoPoint.init(latitude: latitude, longitude: longitude)
        
        // Hide search bar and cancel button 
        self.searchBar.hidden = true
        self.cancelButton.hidden = true
        
        // Set delegates
        self.locationManager.delegate = self
        self.searchBar.delegate = self;
        
        // Add a tap recognizer to dismiss the keyboard when the searchbar is active
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: "viewTapped:")
        self.view.addGestureRecognizer(tapRecognizer)
        
        self.calculateCurrentLocation()
        
        self.addProfileView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Hack to set search bar text color to white..
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).textColor = .whiteColor()
        
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
        
        self.updateUserInfo()
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
                if let geoPoint = geoPoint {
                    LocationStore.sharedStore.updateLocation(geoPoint.latitude, longitude: geoPoint.longitude)
                }
            }
        })
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.searchBar.resignFirstResponder()
        
        self.updateUIForSearch(false)
    }
    
    @IBAction func searchButtonPressed(sender: AnyObject) {
        self.updateUIForSearch(true)
        
        // Make searchbar the first responder
        self.searchBar.becomeFirstResponder()
    }
    
    func viewTapped(sender: UITapGestureRecognizer) {
        if (self.searchBar.isFirstResponder()) {
            self.searchBar.resignFirstResponder()
            self.updateUIForSearch(false)
        }
    }
    
    private func updateUIForSearch(searching: Bool) {
        // Unhide search bar & cancel button
        self.searchBar.hidden = !searching
        self.cancelButton.hidden = !searching
        
        // Unhide cancel button
        self.searchBar.hidden = !searching
        
        // Hide search button & label
        self.searchButton.hidden = searching
        self.klusterTitle.hidden = searching
    }
    
    private func fetchKlusters() {
        var params = [:]
        if let geoPoint = self.currentGeoPoint {
            params = ["latitude" : geoPoint.latitude,
                     "longitude" : geoPoint.longitude]
        }
        
        KlusterDataSource.fetchMainKlusters(params as [NSObject : AnyObject]) { (objects, error) -> Void in
            if let error = error {
                print("Error: %@", error.localizedDescription)
            } else {
                self.klusters = objects as! [PFObject]
                self.collectionView.reloadData()
                self.updateBackground(self.klusters.first)
            }
        }
    }
    
    private func updateBackground(object: PFObject?) {
        if let object = object {
            let k = Kluster.init(object: object)
            self.backgroundImageView.file = k.featuredImageFile
            self.backgroundImageView.loadInBackground()
        }
    }
    
    /** 
     Updates the bottom-right view of the user
     We call this when the view appears in case a user
     changes their name or avatar.
    **/
    private func updateUserInfo() {
        self.userProfileView?.layoutForUser(PFUser.currentUser())
    }
    
    private func addProfileView() {
        let user = PFUser.currentUser()
        let firstName = user?.objectForKey("firstName") as? String
        let maxWidth = self.view.frame.size.width - 200.0
        let font = UIFont.systemFontOfSize(17)
        let labelWidth = self.widthForlabel(firstName, font: font, maxWidth: maxWidth)
        let profileFrame = CGRectMake(0, 0, labelWidth, 40)
        self.userProfileView = ProfileNameView.init(frame: profileFrame)
        if let userProfileView = self.userProfileView {
            userProfileView.layoutForUser(user)
            self.view.addSubview(userProfileView)
            
            let profileRecognizer = UITapGestureRecognizer.init(target: self, action: "profileTapped:")
            userProfileView.addGestureRecognizer(profileRecognizer)
            
            let metrics = ["spacing" : 6]
            let views = ["userProfileView" : userProfileView]
            let profileH = NSLayoutConstraint.constraintsWithVisualFormat("H:[userProfileView]-|", options: NSLayoutFormatOptions(rawValue: 0) , metrics: nil, views: views)
            let profileY = NSLayoutConstraint.constraintsWithVisualFormat("V:[userProfileView]-(spacing)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics  , views: views)
            self.view.addConstraints(profileH)
            self.view.addConstraints(profileY)
        }
    }
    
    private func widthForlabel(text: String?, font: UIFont, maxWidth: CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, maxWidth, CGFloat.max))
        label.numberOfLines = 1
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func profileTapped(sender: UITapGestureRecognizer) {
        let	 storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let profileController = storyboard.instantiateViewControllerWithIdentifier("ProfileViewController")
        self.presentViewController(profileController, animated: true, completion: nil)
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

        let k = Kluster.init(object: self.klusters[indexPath.item])
        cell.kluster = k
        cell.joinKlusterButton.tag = indexPath.row
        cell.joinKlusterButton.addTarget(self, action: "joinKluster:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.joinKlusterButton.hidden = KlusterStore.sharedInstance.userIsMemberOfKluster(k.id)
        
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
        
        // Load avatar images
        let avatarImageViews = [cell.firstAvatarImageView, cell.secondAvatarImageView, cell.thirdAvatarImageView, cell.fourthAvatarImageView]
        let membersQuery = k.memberRelation.query()
        membersQuery.cachePolicy = .CacheElseNetwork
        membersQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            var totalAvatars = 4
            if (objects?.count < avatarImageViews.count) {
                totalAvatars = objects!.count
            }
            
            if (objects!.count > 4) {
                let moreCount = objects!.count - 4
                let buttonText = "\(moreCount) more..."
                cell.moreLabel .setTitle(buttonText, forState: .Normal)
                cell.moreLabel.hidden = false
            } else {
                cell.moreLabel.hidden = true
            }
            
            // Clear the image views...
            for imageView in avatarImageViews {
                imageView.image = nil
            }
            
            var i = 0
            while i < totalAvatars {
                let imageView = avatarImageViews[i]
                let user = objects![i] as? PFUser
                imageView?.file = user?.objectForKey("avatarThumbnail") as? PFFile
                imageView?.loadInBackground()
                i++
                
                imageView.layer.cornerRadius = 12.5
            }
        }
        
        
        
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: "featuredImageViewTapped:")
        cell.featuredImageView.addGestureRecognizer(tapRecognizer)
        return cell
    }
    
    func featuredImageViewTapped(sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let messagesController = storyboard.instantiateViewControllerWithIdentifier("MessagesTableViewController") as! MessagesTableViewController
        let k = Kluster.init(object: self.klusters[(sender.view?.tag)!])
        messagesController.kluster = k
        
        // Show kluster
        let navigationController = MessagesNavigationController.init(rootViewController: messagesController)
        self.presentViewController(navigationController, animated: true, completion: nil);
    }
    
    func joinKluster(sender: UIButton) {
        let k = Kluster.init(object: self.klusters[sender.tag])
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        KlusterDataSource.joinKluster(k.id) { (object, error) -> Void in
            hud.removeFromSuperview()
            if (error != nil) {
                print("Error: %@", error)
            } else {
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                let klusterVC = storyboard.instantiateViewControllerWithIdentifier("KlusterViewController") as! KlusterViewController;
                klusterVC.kluster = k
                // Show kluster
                let navigationController = UINavigationController.init(rootViewController: klusterVC)
                self.presentViewController(navigationController, animated: true, completion: nil);
            }
        }
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

// MARK: - Search delegate
extension HomeViewController : UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let searchString = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if searchString.length > 0 {
            KlusterDataSource.searchForKlusterWithString(searchString) { (objects, error) -> Void in
                if (error != nil) {
                    print("Error: %@", error?.localizedDescription)
                } else {
                    self.klusters = objects as! [PFObject]
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        // Hide search bar...
        
        self.searchBar.resignFirstResponder()
        return true
    }
}


