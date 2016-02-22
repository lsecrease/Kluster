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
    
    //MARK: - UICollectionViewDataSource
    private var klusters = Kluster.createKlusters()
    
    //MARK: - Change Status Bar to White
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    private func showLogin() {
        let storyboard = UIStoryboard.init(name: "Login", bundle: nil)
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.presentViewController(loginVC, animated: true, completion: nil)
    }
    
    @IBAction func searchButtonPressed(sender: AnyObject) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let searchController = storyboard.instantiateViewControllerWithIdentifier("KlusterSearchController") as! KlusterSearchController
        let navigationController = UINavigationController.init(rootViewController: searchController)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
}

extension HomeViewController : UICollectionViewDataSource
{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return klusters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = "Kluster Cell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! KlusterCollectionViewCell
        
        cell.kluster = self.klusters[indexPath.item]
        cell.joinKlusterButton.tag = indexPath.row
        cell.joinKlusterButton.addTarget(self, action: "joinKluster:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: "featuredImageViewTapped:")
        cell.featuredImageView.addGestureRecognizer(tapRecognizer)
        
        return cell
    }
    
    func featuredImageViewTapped(sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let klusterVC = storyboard.instantiateViewControllerWithIdentifier("KlusterViewController") as! KlusterViewController;
        
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


