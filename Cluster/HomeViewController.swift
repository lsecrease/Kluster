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
    
    @IBOutlet weak var currentUserProfileImageButton:UIButton!
    @IBOutlet weak var currentUserFullNameButton:UIButton!
    @IBOutlet weak var profileAvatar: UIImageView!
    //MARK: - UICollectionViewDataSource
    private var klusters = Kluster.createKlusters()
    
    //MARK: - Change Status Bar to White
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

       profileAvatar.layer.cornerRadius = 10.0
        profileAvatar.clipsToBounds = true
        
        var object = PFObject(className: "TestClass")
        object.addObject("iOS-Developers", forKey: "bestSlackGroup")
        object.addObject("iPhone", forKey: "bestSmartPhone")
        object.save()
        
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
        
        return cell
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


