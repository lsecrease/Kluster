//
//  ProfileNameView.swift
//  Cluster
//
//  Created by Michael Fellows on 3/2/16.
//  Copyright © 2016 ImagineME. All rights reserved.
//

import Foundation

class ProfileNameView : UIView {
    
    var avatarImageView: PFImageView = PFImageView()
    var nameLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clearColor()
        
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.avatarImageView)
        self.addSubview(self.nameLabel)
        
        let views = ["avatarImageView" : self.avatarImageView,
                           "nameLabel" : self.nameLabel]
        
        let spacing = 10.0
        let height = Double.init(self.frame.size.height)
        let imageRadius =  height - (2 * spacing)
        let metrics = ["imageViewWidth": imageRadius, "spacing": spacing] as [String : AnyObject]
        
        // Set the corner radius of the avatar view
        self.avatarImageView.layer.cornerRadius = CGFloat(imageRadius / 2.0)
        
        let hConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|[avatarImageView]-(spacing)-[nameLabel]-(spacing)-|",
                                                                         options: NSLayoutFormatOptions(rawValue: 0),
                                                                         metrics:metrics, views: views)
        
        let avatarY = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(spacing)-[avatarImageView]-(spacing)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        let labelY = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(spacing)-[nameLabel]-(spacing)-|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        self.addConstraints(hConstraint)
        self.addConstraints(avatarY)
        self.addConstraints(labelY)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
