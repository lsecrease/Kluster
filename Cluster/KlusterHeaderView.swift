//
//  KlusterHeaderView.swift
//  Cluster
//
//  Created by lsecrease on 10/20/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit

protocol KlusterHeaderViewDelegate {
    func closeButtonClicked()
}

class KlusterHeaderView: UIView {

    //MARK: - Public API
    var kluster: Kluster! {
        didSet {
            updateUI()
        }
    }
    
    var delegate: KlusterHeaderViewDelegate? {
        didSet {
            print("Kluster Header View delegate did set")
        }
    }

    
    private func updateUI() {
        backgroundImageView?.image! = UIImage.init(named: "fashion")! // kluster.featuredImage
        klusterTitleLabel.text! = kluster.title
        numberOfMembers.text! = "\(kluster.numberOfMembers) members"
       
        
    }
    
@IBOutlet weak var backgroundImageView: UIImageView!
@IBOutlet weak var klusterTitleLabel: UILabel!
@IBOutlet weak var numberOfMembers: UILabel!
@IBOutlet var closeButton: UIButton!
    
}
