//
//  MyKlusterViewController.swift
//  Cluster
//
//  Created by Lawrence Olivier on 12/1/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

class MyKlusterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var klusters = [PFObject]()
    
    //MARK: - Change Status Bar to White
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        // Do any additional setup after loading the view.
        KlusterDataSource.fetchKlustersForUser { (objects, error) -> Void in
            hud.removeFromSuperview()
            if (error != nil) {
                let alertController = UIAlertController.init(title: "Error", message: "Something went wrong when fetching your Klusters", preferredStyle: .Alert)
                let action = UIAlertAction.init(title: "OK", style: .Default, handler: nil)
                alertController.addAction(action)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                self.klusters = objects as! [PFObject]
                self.tableView.reloadData()
            }
        }
        
        // Hack to remove unnecessary cell separators
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Hack to set search bar text color to white..
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).textColor = .darkTextColor()
    }
    
    @IBAction func dismiss(sender: UIButton) {
      
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension MyKlusterViewController : UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.klusters.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "My Kluster Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MyKlusterTableViewCell
        

        let k = Kluster.init(object: self.klusters[indexPath.item])
        
        //Cell Elements
        cell.klusterRoleLabel.text = k.creatorString(PFUser.currentUser())
        cell.klusterNameLabel.text = k.title
        cell.numberOfMembersLabel.text = k.memberString()
        
        // Set the image
        cell.klusterImageView.image = nil
        cell.klusterImageView.file = k.featuredImageFile
        cell.klusterImageView.loadInBackground()
        
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // If user is the creator.. return yes.
        let k = Kluster.init(object: self.klusters[indexPath.item])
        let user = PFUser.currentUser()
        return k.creator?.objectId == user?.objectId
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let k = Kluster.init(object: self.klusters[indexPath.row])
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let messagesController = storyboard.instantiateViewControllerWithIdentifier("MessagesTableViewController") as! MessagesTableViewController
        messagesController.kluster = k
        
        // Show kluster
        let navigationController = MessagesNavigationController.init(rootViewController: messagesController)
        self.presentViewController(navigationController, animated: true, completion: nil);
    }
}

extension MyKlusterViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            print("more button tapped")
            let alertController = UIAlertController.init(title: "Are you sure you want to delete this Kluster?", message: "This operation cannot be undone.", preferredStyle: .Alert)
            
            let cancel = UIAlertAction.init(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancel)
            
            let delete = UIAlertAction.init(title: "Delete", style: .Destructive, handler: { (action) -> Void in
                print("Deleting Kluster...")
                let k = Kluster.init(object: self.klusters[indexPath.item])
                
                let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                KlusterDataSource.deleteKluster(k.id, completion: { (object, error) -> Void in
                    hud.removeFromSuperview()
                    if (error != nil) {
                        let errorController = UIAlertController.init(title: "Error", message: "Something went wrong when deleting your Kluster.", preferredStyle: .Alert)
                        
                        let okAction = UIAlertAction.init(title: "OK", style: .Default, handler: nil)
                        errorController.addAction(okAction)
                    } else {
                        self.klusters.removeAtIndex(indexPath.row)
                        self.tableView.reloadData()
                    }
                })
            })
            alertController.addAction(delete)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        delete.backgroundColor = .redColor()
        
        return [delete]
    }
}
