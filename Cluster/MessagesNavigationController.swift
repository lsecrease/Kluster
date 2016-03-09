//
//  MessagesNavigationController.swift
//  Cluster
//
//  Created by Michael Fellows on 3/7/16.
//  Copyright © 2016 ImagineME. All rights reserved.
//

import UIKit

class MessagesNavigationController : UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.translucent = false
        self.navigationBar.barTintColor = .klusterPurpleColor()
        self.navigationBar.tintColor = .whiteColor()
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    }
}
