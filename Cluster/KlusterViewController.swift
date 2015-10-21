//
//  KlusterViewController.swift
//  Cluster
//
//  Created by lsecrease on 10/20/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit

class KlusterViewController: UIViewController {
    
    private var headerView: KlusterHeaderView!
    
    // MARK: -  View Controller Life Cycle
    //Hides the Navigation Bar
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = CGRect(x: 0, y: 0, width: self.view.bounds.origin.x, height: self.view.bounds.origin.y)
        headerView = KlusterHeaderView(frame: frame)
        view.addSubview(headerView)
        
        //HeaderView Delegate
        headerView.delegate = self
        
        
    }


}

//Header View Delegate
extension KlusterViewController : KlusterHeaderViewDelegate {
    func closeButtonClicked() {
        
        println("Close button clicked gets called-dismiss VC")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

