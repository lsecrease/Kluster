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
        
        return cell
    }
    
}
