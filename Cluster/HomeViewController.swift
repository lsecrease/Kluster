//
//  HomeViewController.swift
//  Cluster
//
//  Created by lsecrease on 8/19/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import MBProgressHUD
import ParseUI
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


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
    fileprivate var klusters = [PFObject]()
    var locationManager = CLLocationManager()
    var currentGeoPoint: PFGeoPoint?
    var userProfileView: ProfileNameView?
    
    //MARK: - Change Status Bar to White
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let latitude = LocationStore.sharedStore.currentLatitude()
        let longitude = LocationStore.sharedStore.currentLongitude()
        self.currentGeoPoint = PFGeoPoint.init(latitude: latitude, longitude: longitude)
        
        // Hide search bar and cancel button 
        self.searchBar.isHidden = true
        self.cancelButton.isHidden = true
        
        // Set delegates
        self.locationManager.delegate = self
        self.searchBar.delegate = self;
        
        // Add a tap recognizer to dismiss the keyboard when the searchbar is active
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(HomeViewController.viewTapped(_:)))
        self.view.addGestureRecognizer(tapRecognizer)
        
        self.calculateCurrentLocation()
        
        self.addProfileView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Hack to set search bar text color to white..
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = .white
        
        self.fetchKlusters()
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        let locationAuthorized = authorizationStatus == .authorizedWhenInUse
        self.createKlusterButton.isEnabled = locationAuthorized
        if (locationAuthorized) {
            self.locationManager.startUpdatingLocation()
        } else {
            // let's request location authorization
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        self.updateUserInfo()
    }
    
    // MARK: IBActions
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.searchBar.resignFirstResponder()
        
        self.updateUIForSearch(false)
    }
    
    @IBAction func searchButtonPressed(_ sender: AnyObject) {
        self.updateUIForSearch(true)
        
        // Make searchbar the first responder
        self.searchBar.becomeFirstResponder()
    }

    
    // MARK: Custom functions
    
    fileprivate func showLogin() {
        let storyboard = UIStoryboard.init(name: "Login", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(loginVC, animated: true, completion: nil)
    }
    
    fileprivate func calculateCurrentLocation() {
        PFGeoPoint.geoPointForCurrentLocation(inBackground: { (geoPoint, error) -> Void in
            if (error == nil) {
                self.currentGeoPoint = geoPoint
                if let geoPoint = geoPoint {
                    LocationStore.sharedStore.updateLocation(geoPoint.latitude, longitude: geoPoint.longitude)
                }
            }
        })
    }
    
    
    func viewTapped(_ sender: UITapGestureRecognizer) {
        if (self.searchBar.isFirstResponder) {
            self.searchBar.resignFirstResponder()
            self.updateUIForSearch(false)
        }
    }
    
    fileprivate func updateUIForSearch(_ searching: Bool) {
        // Unhide search bar & cancel button
        self.searchBar.isHidden = !searching
        self.cancelButton.isHidden = !searching
        
        // Unhide cancel button
        self.searchBar.isHidden = !searching
        
        // Hide search button & label
        self.searchButton.isHidden = searching
        self.klusterTitle.isHidden = searching
    }
    
    fileprivate func fetchKlusters() {
        var params = [String : Any]()
        if let geoPoint = self.currentGeoPoint {
            params = ["latitude" : geoPoint.latitude,
                     "longitude" : geoPoint.longitude]
        }
        
        KlusterDataSource.fetchMainKlusters(params as [AnyHashable: Any]) { (objects, error) -> Void in
            if let error = error {
                print("Error: %@", error.localizedDescription)
            } else {
                self.klusters = objects as! [PFObject]
                self.collectionView.reloadData()
                self.updateBackground(self.klusters.first)
            }
        }
    }
    
    fileprivate func updateBackground(_ object: PFObject?) {
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
    fileprivate func updateUserInfo() {
        self.userProfileView?.layoutForUser(PFUser.current())
    }
    
    fileprivate func addProfileView() {
        let user = PFUser.current()
        let firstName = user?.object(forKey: "firstName") as? String
        let maxWidth = self.view.frame.size.width - 200.0
        let font = UIFont.systemFont(ofSize: 17)
        let labelWidth = self.widthForlabel(firstName, font: font, maxWidth: maxWidth)
        let profileFrame = CGRect(x: 0, y: 0, width: labelWidth, height: 40)
        self.userProfileView = ProfileNameView.init(frame: profileFrame)
        if let userProfileView = self.userProfileView {
            userProfileView.layoutForUser(user)
            self.view.addSubview(userProfileView)
            
            let profileRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(HomeViewController.profileTapped(_:)))
            userProfileView.addGestureRecognizer(profileRecognizer)
            
            let metrics = ["spacing" : 6]
            let views = ["userProfileView" : userProfileView]
            let profileH = NSLayoutConstraint.constraints(withVisualFormat: "H:[userProfileView]-|", options: NSLayoutFormatOptions(rawValue: 0) , metrics: nil, views: views)
            let profileY = NSLayoutConstraint.constraints(withVisualFormat: "V:[userProfileView]-(spacing)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics  , views: views)
            self.view.addConstraints(profileH)
            self.view.addConstraints(profileY)
        }
    }
    
    fileprivate func widthForlabel(_ text: String?, font: UIFont, maxWidth: CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 1
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func profileTapped(_ sender: UITapGestureRecognizer) {
        let	 storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let profileController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController")
        self.present(profileController, animated: true, completion: nil)
    }
}


// MARK: - UICollectionViewDataSource

extension HomeViewController : UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.klusters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = "Kluster Cell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! KlusterCollectionViewCell

        let k = Kluster.init(object: self.klusters[indexPath.item])
        cell.kluster = k
        cell.joinKlusterButton.tag = indexPath.row
        cell.joinKlusterButton.addTarget(self, action: #selector(HomeViewController.joinKluster(_:)), for: UIControlEvents.touchUpInside)
        cell.joinKlusterButton.isHidden = KlusterStore.sharedInstance.userIsMemberOfKluster(k.id)
        
        cell.distanceLabel.text = k.distanceToKluster(self.currentGeoPoint)
        
        // Moved the PFImageView loading out of the cell
        cell.featuredImageView.tag = indexPath.row
        cell.featuredImageView.image = nil
        cell.featuredImageView.file = k.featuredImageFile
        cell.featuredImageView.load { (image, error) -> Void in
            if (error != nil) {
                print("Error loading image...")
            } else {
                print("Finished loading image...")
                DispatchQueue.main.async(execute: { () -> Void in
                    cell.featuredImageView.image = image
                });
            }
        }
        
        // Load avatar images
        let avatarImageViews = [cell.firstAvatarImageView, cell.secondAvatarImageView, cell.thirdAvatarImageView, cell.fourthAvatarImageView]
        let membersQuery = k.memberRelation.query()
        membersQuery.cachePolicy = .cacheElseNetwork
        membersQuery.findObjectsInBackground { (objects, error) -> Void in
            
            var totalAvatars = 4
            if (objects?.count < avatarImageViews.count) {
                totalAvatars = objects!.count
            }
            
            if (objects!.count > 4) {
                let moreCount = objects!.count - 4
                let buttonText = "\(moreCount) more..."
                cell.moreLabel .setTitle(buttonText, for: UIControlState())
                cell.moreLabel.isHidden = false
            } else {
                cell.moreLabel.isHidden = true
            }
            
            // Clear the image views...
            for imageView in avatarImageViews {
                imageView?.image = nil
            }
            
            var i = 0
            while i < totalAvatars {
                let imageView = avatarImageViews[i]
                let user = objects![i] as? PFUser
                imageView?.file = user?.object(forKey: "avatarThumbnail") as? PFFile
                imageView?.loadInBackground()
                i += 1
                
                imageView?.layer.cornerRadius = 12.5
            }
        }
        
        
        
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(HomeViewController.featuredImageViewTapped(_:)))
        cell.featuredImageView.addGestureRecognizer(tapRecognizer)
        return cell
    }
    
    func featuredImageViewTapped(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let messagesController = storyboard.instantiateViewController(withIdentifier: "MessagesTableViewController") as! MessagesTableViewController
        let k = Kluster.init(object: self.klusters[(sender.view?.tag)!])
        messagesController.kluster = k
        
        // Show kluster
        let navigationController = MessagesNavigationController.init(rootViewController: messagesController)
        self.present(navigationController, animated: true, completion: nil);
    }
    
    func joinKluster(_ sender: UIButton) {
        let k = Kluster.init(object: self.klusters[sender.tag])
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        KlusterDataSource.joinKluster(k.id as NSString!) { (object, error) -> Void in
            hud.removeFromSuperview()
            if (error != nil) {
                print("Error: %@", error)
            } else {
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                let klusterVC = storyboard.instantiateViewController(withIdentifier: "KlusterViewController") as! KlusterViewController;
                klusterVC.kluster = k
                // Show kluster
                let navigationController = UINavigationController.init(rootViewController: klusterVC)
                self.present(navigationController, animated: true, completion: nil);
            }
        }
    }
}


// MARK: - CLLocationManager Delegate function(s)

extension HomeViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse) {
            self.calculateCurrentLocation()
        }
    }
}


//MARK: - Scrolling Experience
extension HomeViewController : UIScrollViewDelegate
{
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
        
    }
}

// MARK: - Search delegate
extension HomeViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchString = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
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
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        // Hide search bar...
        
        self.searchBar.resignFirstResponder()
        return true
    }
}


