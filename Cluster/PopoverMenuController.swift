//
//  PopoverMenuController.swift
//  Cluster
//
//  Created by Michael Fellows on 3/5/16.
//  Copyright © 2016 ImagineME. All rights reserved.
//

import UIKit

enum PopoverTableSection: Int {
    case Members = 0, Invite, Settings, Count
}

class PopoverMenuController : UIViewController {
    
    var tableView: UITableView = UITableView.init(frame: CGRectZero, style: .Plain)
    var dismissView: UIView = UIView()
    var originalTableX: CGFloat?
    let animationTimeInterval: NSTimeInterval = 0.3
    let backgroundViewAlpha: CGFloat = 0.4
    var kluster: Kluster!
    let headerHeight: CGFloat = 300.0
    var headerView: PopoverHeaderView!
    var headerFrame: CGRect!
    var originalHeaderImageViewFrame: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        
        let tableViewWidthPercentage: CGFloat = 0.6
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        self.originalTableX = CGFloat(width * (1.0 - tableViewWidthPercentage))
        let tableViewFrame = CGRectMake(width,
        0.0, width * tableViewWidthPercentage, height)
        
        self.dismissView.frame = CGRectMake(0, 0, width * (1.0 - tableViewWidthPercentage), height)
        self.dismissView.backgroundColor = .clearColor()
        self.view.addSubview(self.dismissView)
        
        // Add tap recognizer to view to dismiss the popover
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: "viewTapped:")
        self.dismissView.addGestureRecognizer(tapRecognizer)
        
        self.tableView.frame = tableViewFrame
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        self.headerFrame = CGRectMake(0, 0, self.tableView.frame.size.width, self.headerHeight)
        self.headerView = PopoverHeaderView.init(frame: self.headerFrame)
        self.headerView.kluster = self.kluster
        self.originalHeaderImageViewFrame = self.headerView.headerImageView.frame
        
        self.tableView.tableHeaderView = self.headerView
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.fadeInTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.hidden = true
    }
    
    private func fadeInTableView() {
        
        // Make sure the table view is in the original animating position off screen
        if (self.tableView.frame.origin.x < self.view.frame.size.width) {
            return
        }
        
        UIView.animateWithDuration(self.animationTimeInterval, delay: 0.0, options:UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.tableView.frame = self.tableView.frame
            
                // Update background color
                self.view.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
            }, completion: nil)
        
        UIView.animateWithDuration(self.animationTimeInterval, delay: 0.0, options:UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                var newFrame = self.tableView.frame
                newFrame.origin.x = self.originalTableX!
                self.tableView.frame = newFrame
            
                self.view.backgroundColor = UIColor(white: 0.0, alpha: self.backgroundViewAlpha)
            }, completion: nil)
    }
    
    private func fadeOutTableView() {
        UIView.animateWithDuration(self.animationTimeInterval, delay: 0.0, options:UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.tableView.frame = self.tableView.frame
            
                self.view.backgroundColor = self.view.backgroundColor
            }, completion: nil)
        
        UIView.animateWithDuration(self.animationTimeInterval, delay: 0.0, options:UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                var newFrame = self.tableView.frame
                newFrame.origin.x = self.view.frame.size.width
                self.tableView.frame = newFrame
            
                self.view.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
            }) { (completed) -> Void in
                self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    func viewTapped(sender: AnyObject?) {
        self.fadeOutTableView()
    }
}

extension PopoverMenuController : UITableViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print("Scrolled to y: %f", scrollView.bounds.origin.y)
        
        let y = scrollView.bounds.origin.y
        if (y <= 0.0) {
            // Adjust the frame...
            var headerImageFrame = self.originalHeaderImageViewFrame
            headerImageFrame.origin.y = y //CGFloat(headerImageFrame.size.height + y)
            headerImageFrame.size.height = self.originalHeaderImageViewFrame.size.height - y
            self.headerView.headerImageView.frame = headerImageFrame
        }
    }
}

extension PopoverMenuController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier")
        if (cell == nil) {
            cell = UITableViewCell.init(style: .Default, reuseIdentifier: "CellIdentifier")
        }
        
        cell?.textLabel?.text = self.cellTitle(indexPath.row)
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.navigationController?.navigationBar.hidden = false
        
        switch(indexPath.row) {
        case PopoverTableSection.Members.rawValue:
            print("Show members")
        case PopoverTableSection.Invite.rawValue:
            print("Show Invite")
        case PopoverTableSection.Settings.rawValue:
            print("Show settings")
        default:
            break
            
        }
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let memberController = storyBoard.instantiateViewControllerWithIdentifier("MembersTableViewController") as! MembersTableViewController
        memberController.kluster = self.kluster
        self.navigationController?.pushViewController(memberController, animated: true)
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PopoverTableSection.Count.rawValue
    }
    
    private func cellTitle(row: Int) -> String {
        switch(row) {
        case PopoverTableSection.Members.rawValue:
            if (self.kluster.numberOfMembers == 1) {
                return "\(self.kluster.numberOfMembers) Member"
            } else {
                return "\(self.kluster.numberOfMembers) Members"
            }
        case PopoverTableSection.Invite.rawValue:
            return "Invite Friends"
        case PopoverTableSection.Settings.rawValue:
            return "Settings"
        default:
            return ""
        }
    }
}