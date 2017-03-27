//
//  KlusterViewController.swift
//  Cluster
//
//  Created by lsecrease on 10/20/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit

//MARK: - KlusterViewController

class KlusterViewController: UIViewController, CAPSPageMenuDelegate {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var headerView: KlusterHeaderView!
    
    // MARK: Variables and constants
    
    var kluster: Kluster!
    var pageMenu: CAPSPageMenu?
    var menuHeight: CGFloat = 150.0
    
    // MARK: -  View Controller Life Cycle
    //Hides the Navigation Bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.headerView.kluster = self.kluster
        self.headerView.closeButton!.addTarget(self, action: #selector(KlusterViewController.dismissViewController(_:)), for: UIControlEvents.touchUpInside)
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)

        let messagesController = storyBoard.instantiateViewController(withIdentifier: "MessagesTableViewController") as! MessagesTableViewController
        messagesController.kluster = self.kluster
        messagesController.title = "MESSAGES"
        messagesController.parentNavigationController = self.navigationController
        controllerArray.append(messagesController)
        
        let memberController = storyBoard.instantiateViewController(withIdentifier: "MembersTableViewController") as! MembersTableViewController
        memberController.kluster = self.kluster
        memberController.parentNavigationController = self.navigationController
        memberController.title = "MEMBERS"
        controllerArray.append(memberController)
        
        // Customize menu (Optional)
        let parameters: [CAPSPageMenuOption] = [
            .menuItemSeparatorWidth(4.3),
            .scrollMenuBackgroundColor(UIColor.white),
            .viewBackgroundColor(UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)),
            .bottomMenuHairlineColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 0.1)),
            .selectionIndicatorColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .menuMargin(20.0),
            .menuHeight(40.0),
            .selectedMenuItemLabelColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .unselectedMenuItemLabelColor(UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1.0)),
            .menuItemFont(UIFont(name: "HelveticaNeue-Medium", size: 14.0)!),
            .useMenuLikeSegmentedControl(true),
            .menuItemSeparatorRoundEdges(true),
            .selectionIndicatorHeight(2.0),
            .menuItemSeparatorPercentageHeight(0.1)
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: self.menuHeight, width: self.view.frame.width, height: self.view.frame.height - self.menuHeight), pageMenuOptions: parameters)
        
        // Optional delegate
        pageMenu!.delegate = self
        self.view.addSubview(pageMenu!.view)
    }
    
    // MARK: Custom functions
    
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        print("did move to page")
    }
    func willMoveToPage(_ controller: UIViewController, index: Int) {
        print("will move to page")
    }
    
    func dismissViewController(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

