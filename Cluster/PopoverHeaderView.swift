//
//  PopoverHeaderView.swift
//  Cluster
//
//  Created by Michael Fellows on 3/7/16.
//  Copyright © 2016 ImagineME. All rights reserved.
//

import UIKit
import ParseUI

class PopoverHeaderView: UIView {
    
    var headerImageView: PFImageView = PFImageView()
    var headerLabel = UILabel()
    var kluster: Kluster? {
        didSet {
            updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.headerImageView.frame = self.bounds // CGRectMake(0, 0, self.frame.size.width, imageHeight)
        self.headerImageView.contentMode = .scaleAspectFill
        self.headerImageView.clipsToBounds = true
        self.addSubview(self.headerImageView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func updateUI() {
        self.headerImageView.file = self.kluster?.featuredImageFile
        self.headerImageView.loadInBackground()
    }
}
