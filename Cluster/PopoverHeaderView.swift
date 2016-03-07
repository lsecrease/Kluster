//
//  PopoverHeaderView.swift
//  Cluster
//
//  Created by Michael Fellows on 3/7/16.
//  Copyright © 2016 ImagineME. All rights reserved.
//

import UIKit

class PopoverHeaderView: UIView {
    
    var headerImageView: PFImageView = PFImageView()
    var headerLabel = UILabel()
    let labelHeight: CGFloat = 80.0
    var kluster: Kluster? {
        didSet {
            updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageHeight = self.frame.size.height - labelHeight
        self.headerImageView.frame = CGRectMake(0, 0, self.frame.size.width, imageHeight)
        self.headerImageView.contentMode = .ScaleAspectFill
        self.headerImageView.clipsToBounds = true
        self.addSubview(self.headerImageView)
        
        self.headerLabel.frame = CGRectMake(0, imageHeight, self.frame.size.width, self.labelHeight)
        self.headerLabel.textAlignment = .Center
        self.headerLabel.lineBreakMode = .ByWordWrapping
        self.headerLabel.numberOfLines = 2
        self.addSubview(self.headerLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func updateUI() {
        self.headerImageView.file = self.kluster?.featuredImageFile
        self.headerImageView.loadInBackground()
        
        self.headerLabel.text = self.kluster?.title
    }
}
