//
//  PopoverMenuController.swift
//  Cluster
//
//  Created by Michael Fellows on 3/5/16.
//  Copyright © 2016 ImagineME. All rights reserved.
//

import UIKit

enum PopoverTableSection: Int {
    case title = 0, description, members, invite, count
}

class PopoverMenuController : UIViewController {
    
    var tableView: UITableView = UITableView.init(frame: CGRect.zero, style: .plain)
    var dismissView: UIView = UIView()
    var originalTableX: CGFloat?
    let animationTimeInterval: TimeInterval = 0.3
    let backgroundViewAlpha: CGFloat = 0.4
    var kluster: Kluster!
    let headerHeight: CGFloat = 250.0
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
        let tableViewFrame = CGRect(x: width,
        y: 0.0, width: width * tableViewWidthPercentage, height: height)
        
        self.dismissView.frame = CGRect(x: 0, y: 0, width: width * (1.0 - tableViewWidthPercentage), height: height)
        self.dismissView.backgroundColor = .clear
        self.view.addSubview(self.dismissView)
        
        // Add tap recognizer to view to dismiss the popover
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(PopoverMenuController.viewTapped(_:)))
        self.dismissView.addGestureRecognizer(tapRecognizer)
        
        self.tableView.frame = tableViewFrame
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        self.headerFrame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: self.headerHeight)
        self.headerView = PopoverHeaderView.init(frame: self.headerFrame)
        self.headerView.kluster = self.kluster
        self.originalHeaderImageViewFrame = self.headerView.headerImageView.frame
        
        self.tableView.tableHeaderView = self.headerView
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.fadeInTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    fileprivate func fadeInTableView() {
        
        // Make sure the table view is in the original animating position off screen
        if (self.tableView.frame.origin.x < self.view.frame.size.width) {
            return
        }
        
        UIView.animate(withDuration: self.animationTimeInterval, delay: 0.0, options:UIViewAnimationOptions(), animations: { () -> Void in
                self.tableView.frame = self.tableView.frame
            
                // Update background color
                self.view.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
            }, completion: nil)
        
        UIView.animate(withDuration: self.animationTimeInterval, delay: 0.0, options:UIViewAnimationOptions(), animations: { () -> Void in
                var newFrame = self.tableView.frame
                newFrame.origin.x = self.originalTableX!
                self.tableView.frame = newFrame
            
                self.view.backgroundColor = UIColor(white: 0.0, alpha: self.backgroundViewAlpha)
            }, completion: nil)
    }
    
    fileprivate func fadeOutTableView() {
        UIView.animate(withDuration: self.animationTimeInterval, delay: 0.0, options:UIViewAnimationOptions(), animations: { () -> Void in
                self.tableView.frame = self.tableView.frame
            
                self.view.backgroundColor = self.view.backgroundColor
            }, completion: nil)
        
        UIView.animate(withDuration: self.animationTimeInterval, delay: 0.0, options:UIViewAnimationOptions(), animations: { () -> Void in
                var newFrame = self.tableView.frame
                newFrame.origin.x = self.view.frame.size.width
                self.tableView.frame = newFrame
            
                self.view.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
            }) { (completed) -> Void in
                self.dismiss(animated: false, completion: nil)
        }
    }
    
    func viewTapped(_ sender: AnyObject?) {
        self.fadeOutTableView()
    }
}

extension PopoverMenuController : UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("Scrolled to y: %f", scrollView.bounds.origin.y)
        
        let y = scrollView.bounds.origin.y
        if (y <= 0.0) {
            // Adjust the frame...
            var headerImageFrame = self.originalHeaderImageViewFrame
            headerImageFrame?.origin.y = y //CGFloat(headerImageFrame.size.height + y)
            headerImageFrame?.size.height = self.originalHeaderImageViewFrame.size.height - y
            self.headerView.headerImageView.frame = headerImageFrame!
        }
    }
}

extension PopoverMenuController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier")
        if (cell == nil) {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "CellIdentifier")
        }
        
        cell?.textLabel?.text = self.cellTitle(indexPath.row)
        cell?.selectionStyle = .none
        
        if (indexPath.row == PopoverTableSection.title.rawValue) {
            cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
            cell?.accessoryType = .none
        } else if (indexPath.row == PopoverTableSection.description.rawValue) {
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
            cell?.textLabel?.textColor = UIColor.lightGray
            cell?.accessoryType = .none
        } else {
            cell?.accessoryType = .disclosureIndicator
        }
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.navigationBar.isHidden = false
        
        switch(indexPath.row) {
        case PopoverTableSection.members.rawValue:
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let memberController = storyBoard.instantiateViewController(withIdentifier: "MembersTableViewController") as! MembersTableViewController
            memberController.kluster = self.kluster
            self.navigationController?.pushViewController(memberController, animated: true)
        case PopoverTableSection.invite.rawValue:
            self.showInvitationController()
        default:
            break
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == PopoverTableSection.title.rawValue) {
            return self.heightForString(self.kluster.title, font: UIFont.systemFont(ofSize: 18))
        } else if (indexPath.row == PopoverTableSection.description.rawValue) {
            return self.heightForString(self.kluster.summary, font: UIFont.systemFont(ofSize: 16))
        }
        
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PopoverTableSection.count.rawValue
    }
    
    fileprivate func cellTitle(_ row: Int) -> String {
        switch(row) {
        case PopoverTableSection.members.rawValue:
            if (self.kluster.numberOfMembers == 1) {
                return "\(self.kluster.numberOfMembers) Member"
            } else {
                return "\(self.kluster.numberOfMembers) Members"
            }
        case PopoverTableSection.invite.rawValue:
            return "Invite Friends"
            
        case PopoverTableSection.title.rawValue:
            return self.kluster.title
            
        case PopoverTableSection.description.rawValue:
            return self.kluster.summary!
            
        default:
            return ""
        }
    }
    
    fileprivate func heightForString(_ string: String?, font: UIFont?) -> CGFloat {
        if (string == nil || font == nil) {
            return 60.0
        }
        return 60.0
    }
    
    fileprivate func showInvitationController() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let inviteController = storyboard.instantiateViewController(withIdentifier: "KlusterInviteViewController") as? KlusterInviteViewController {
            inviteController.kluster = self.kluster
            self.navigationController?.pushViewController(inviteController, animated: true)
        }
    }
}
