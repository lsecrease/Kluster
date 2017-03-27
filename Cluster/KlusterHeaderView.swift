//
//  KlusterHeaderView.swift
//  Cluster
//
//  Created by lsecrease on 10/20/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit

// MARK: KlusterHeaderViewDelegate

protocol KlusterHeaderViewDelegate {
    func closeButtonClicked()
}

// MARK: - KlusterHeaderView

class KlusterHeaderView: UIView {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var klusterTitleLabel: UILabel!
    @IBOutlet weak var numberOfMembers: UILabel!
    @IBOutlet var closeButton: UIButton!


    //MARK: - Public API
    
    var kluster: Kluster! {
        didSet {
            updateUI()
        }
    }
    
    // MARK: Delegate
    
    var delegate: KlusterHeaderViewDelegate? {
        didSet {
            print("Kluster Header View delegate did set")
        }
    }

    
    // MARK: UI functions
    
    fileprivate func updateUI() {
        backgroundImageView?.image! = UIImage.init(named: "fashion")! // kluster.featuredImage
        klusterTitleLabel.text! = kluster.title
        numberOfMembers.text! = "\(kluster.numberOfMembers) members"
       
        
    }
    
    
}
