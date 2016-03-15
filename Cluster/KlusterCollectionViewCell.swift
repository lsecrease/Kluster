//
//  KlusterCollectionViewCell.swift
//  Cluster
//
//  Created by lsecrease on 9/12/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit

class KlusterCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Public API
    var kluster: Kluster! {
        didSet {
            updateUI()
        }
        
    }
    //MARK: - Private
    
    @IBOutlet weak var featuredImageView: PFImageView!
    @IBOutlet weak var klusterTitleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var joinKlusterButton: UIButton!
    @IBOutlet weak var firstAvatarImageView: PFImageView!
    @IBOutlet weak var secondAvatarImageView: PFImageView!
    @IBOutlet weak var thirdAvatarImageView: PFImageView!
    @IBOutlet weak var fourthAvatarImageView: PFImageView!
    @IBOutlet weak var moreLabel: UIButton!
    
    private func updateUI() {
        self.klusterTitleLabel?.text! = kluster.title
        distanceLabel?.text! = kluster.distanceString // kluster.location
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
    }

    @IBAction func joinKlusterButtonTapped(sender: AnyObject) {
    }

}
