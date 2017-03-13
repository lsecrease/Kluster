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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = .klusterPurpleColor()
        self.navigationBar.tintColor = .white
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }
}
