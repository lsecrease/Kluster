//
//  KlusterViewController.swift
//  Cluster
//
//  Created by lsecrease on 10/20/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit

class KlusterViewController: UIViewController, CAPSPageMenuDelegate {
    
    @IBOutlet weak var headerView: KlusterHeaderView!
    
    var pageMenu: CAPSPageMenu?
    
    // MARK: -  View Controller Life Cycle
    //Hides the Navigation Bar
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.headerView.closeButton!.addTarget(self, action: "dismissViewController:", forControlEvents: UIControlEvents.TouchUpInside)
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        
        let controller1 = storyBoard.instantiateViewControllerWithIdentifier("MembersTableViewController") as! MembersTableViewController
        controller1.parentNavigationController = self.navigationController
        controller1.title = "MEMBERS"
        controllerArray.append(controller1)
        
        let controller2 = storyBoard.instantiateViewControllerWithIdentifier("MessagesTableViewController") as! MessagesTableViewController
        controller2.title = "MESSAGES"
        controller2.parentNavigationController = self.navigationController
        controllerArray.append(controller2)
        
        // Customize menu (Optional)
        let parameters: [CAPSPageMenuOption] = [
            .MenuItemSeparatorWidth(4.3),
            .ScrollMenuBackgroundColor(UIColor.whiteColor()),
            .ViewBackgroundColor(UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)),
            .BottomMenuHairlineColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 0.1)),
            .SelectionIndicatorColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .MenuMargin(20.0),
            .MenuHeight(40.0),
            .SelectedMenuItemLabelColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .UnselectedMenuItemLabelColor(UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1.0)),
            .MenuItemFont(UIFont(name: "HelveticaNeue-Medium", size: 14.0)!),
            .UseMenuLikeSegmentedControl(true),
            .MenuItemSeparatorRoundEdges(true),
            .SelectionIndicatorHeight(2.0),
            .MenuItemSeparatorPercentageHeight(0.1)
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 150.0, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
        
        // Optional delegate
        pageMenu!.delegate = self
        
        self.view.addSubview(pageMenu!.view)
    }
    
    func didMoveToPage(controller: UIViewController, index: Int) {
        print("did move to page")
    }
    func willMoveToPage(controller: UIViewController, index: Int) {
        print("will move to page")
    }
    
    func dismissViewController(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

