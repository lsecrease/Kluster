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
    @IBOutlet weak var featuredImageView: UIImageView!
    @IBOutlet weak var klusterTitleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var joinKlusterButton: UIButton!
    
    
    private func updateUI() {
        
        klusterTitleLabel?.text! = kluster.title
        featuredImageView?.image! = kluster.featuredImage
        distanceLabel?.text! = kluster.distance
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
        
        
    }

    @IBAction func joinKlusterButtonTapped(sender: AnyObject) {
    }

}
