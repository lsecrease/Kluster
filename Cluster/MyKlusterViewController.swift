//
//  MyKlusterViewController.swift
//  Cluster
//
//  Created by Lawrence Olivier on 12/1/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import MBProgressHUD
import UIKit

class MyKlusterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var klusters = [PFObject]()
    
    //MARK: - Change Status Bar to White
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        // Do any additional setup after loading the view.
        KlusterDataSource.fetchKlustersForUser { (objects, error) -> Void in
            hud?.removeFromSuperview()
            if (error != nil) {
                let alertController = UIAlertController.init(title: "Error", message: "Something went wrong when fetching your Klusters", preferredStyle: .alert)
                let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.klusters = objects as! [PFObject]
                self.tableView.reloadData()
            }
        }
        
        // Hack to remove unnecessary cell separators
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Hack to set search bar text color to white..
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = .darkText
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
      
        self.dismiss(animated: true, completion: nil)
    }
}

extension MyKlusterViewController : UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.klusters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "My Kluster Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MyKlusterTableViewCell
        

        let k = Kluster.init(object: self.klusters[indexPath.item])
        
        //Cell Elements
        cell.klusterRoleLabel.text = k.creatorString(PFUser.current())
        cell.klusterNameLabel.text = k.title
        cell.numberOfMembersLabel.text = k.memberString()
        
        // Set the image
        cell.klusterImageView.image = nil
        cell.klusterImageView.file = k.featuredImageFile
        cell.klusterImageView.loadInBackground()
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // If user is the creator.. return yes.
        let k = Kluster.init(object: self.klusters[indexPath.item])
        let user = PFUser.current()
        return k.creator?.objectId == user?.objectId
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let k = Kluster.init(object: self.klusters[indexPath.row])
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let messagesController = storyboard.instantiateViewController(withIdentifier: "MessagesTableViewController") as! MessagesTableViewController
        messagesController.kluster = k
        
        // Show kluster
        let navigationController = MessagesNavigationController.init(rootViewController: messagesController)
        self.present(navigationController, animated: true, completion: nil);
    }
}

extension MyKlusterViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("more button tapped")
            let alertController = UIAlertController.init(title: "Are you sure you want to delete this Kluster?", message: "This operation cannot be undone.", preferredStyle: .alert)
            
            let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancel)
            
            let delete = UIAlertAction.init(title: "Delete", style: .destructive, handler: { (action) -> Void in
                print("Deleting Kluster...")
                let k = Kluster.init(object: self.klusters[indexPath.item])
                
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                KlusterDataSource.deleteKluster(k.id, completion: { (object, error) -> Void in
                    hud!.removeFromSuperview()
                    if (error != nil) {
                        let errorController = UIAlertController.init(title: "Error", message: "Something went wrong when deleting your Kluster.", preferredStyle: .alert)
                        
                        let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                        errorController.addAction(okAction)
                    } else {
                        self.klusters.remove(at: indexPath.row)
                        self.tableView.reloadData()
                    }
                })
            })
            alertController.addAction(delete)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        delete.backgroundColor = .red
        
        return [delete]
    }
}
