//
//  MessagesTableViewController.swift
//  Cluster
//
//  Created by lsecrease on 10/21/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit

class MessagesTableViewController: UITableViewController {
    
    var parentNavigationController : UINavigationController?
    
    var kluster: Kluster!
    var textView: MessageTextView!
    let textViewHeight = 60.0 as CGFloat
    var messages = [PFObject]()
    let windowHeight: CGFloat? = UIApplication.sharedApplication().keyWindow?.frame.size.height
    
//    init(style: UITableViewStyle) {
//        super.init(tableViewStyle: .Plain)
//    }
//
//    required init!(coder decoder: NSCoder!) {
//        super.init(tableViewStyle: .Plain)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchMessages()

        // Update the keyboard status
        self.textView = MessageTextView.init(frame: self.originalFrame())
        self.textView.sendButton.addTarget(self, action: "sendPressed:", forControlEvents: .TouchUpInside)
        UIApplication.sharedApplication().keyWindow?.addSubview(self.textView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Bit of a hack below. PageViewController prevents ViewWillAppear from being called on the initial load
        self.textView.frame = self.originalFrame()
        UIApplication.sharedApplication().keyWindow?.addSubview(self.textView)
        
        self.fetchMessages()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        self.textView.frame = self.originalFrame()
        self.textView.removeFromSuperview()
    }
    
    func sendPressed(sender: UIButton) {
        let text = self.textView.textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (text?.length > 0) {
            
            self.textView.textField.text = ""
            self.textView.textField.resignFirstResponder()
            
            KlusterDataSource.createMessageInKluster(self.kluster.id, text: text!, completion: { (object, error) -> Void in
                if (error != nil) {
                    print("Message failed to send...")
                } else {
                    print("Message sent...")
                    self.fetchMessages()
                }
            })
        }
    }
    
    private func fetchMessages() {
        KlusterDataSource.fetchMessagesInKluster(self.kluster.id, skip: 0) { (objects, error) -> Void in
            if (error != nil) {
                print("Error fetching messages.")
            } else {
                self.messages = objects as! [PFObject]
                self.tableView.reloadData()
            }
        }
    }

    
    private func originalFrame() -> CGRect {
        let y = UIApplication.sharedApplication().keyWindow!.frame.size.height - textViewHeight //  + 190.0
        return CGRectMake(0, y, self.view.frame.size.width, textViewHeight)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.messages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! MessageTableViewCell
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageTableViewCell", forIndexPath: indexPath) as! MessageTableViewCell
        
        let message = Message.init(object: self.messages[indexPath.row])
        let user = message.user
        
        cell.messageLabel.text = message.text
        
        let firstName = user?.objectForKey("firstName") as! String
        let lastName = user?.objectForKey("lastName") as! String
        // Configure the cell...
        cell.nameLabel.text = firstName + " " + lastName
        
        cell.avatarImageView.image = nil
        cell.avatarImageView.tag = indexPath.row
        cell.avatarImageView.userInteractionEnabled = true
        cell.avatarImageView.file = user?.objectForKey("avatarThumbnail") as? PFFile
        cell.avatarImageView.loadInBackground()
        cell.selectionStyle = .None
        
        // Add a tap recognizer to the cell
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: "avatarTapped:")
        cell.avatarImageView.addGestureRecognizer(tapRecognizer)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 68
    }

    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return textViewHeight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.textView.textField.resignFirstResponder()
    }
    
    // MARK: - Notifications
    
    func keyboardWillShowNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification, hide: false)
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        updateBottomLayoutConstraintWithNotification(notification, hide: true)
    }
    
    // MARK: - Selector
    
    func avatarTapped(sender: UITapGestureRecognizer) {
        let message = Message.init(object: self.messages[sender.view!.tag])
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let profileViewController = storyboard.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        profileViewController.user = message.user
        self.presentViewController(profileViewController, animated: true, completion: nil)
    }
    
    
    // MARK: - Private
    
    func updateBottomLayoutConstraintWithNotification(notification: NSNotification, hide: Bool) {
        let userInfo = notification.userInfo!
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let convertedKeyboardEndFrame = view.convertRect(keyboardEndFrame, fromView: view.window)
        let rawAnimationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedIntValue << 16
        let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
        
        print("Converted keyboard end frame height: %f", convertedKeyboardEndFrame.size.height)
        
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: animationCurve, animations: { () -> Void in
            var frame = self.textView.frame
            if (hide) {
                // Bring the textView back to it's original frame
                self.textView.frame = self.originalFrame()
            } else {
                frame.origin.y =  self.windowHeight! - convertedKeyboardEndFrame.size.height - self.textViewHeight
                self.textView.frame = frame
            }
            }) { (finished) -> Void in
        }
    }
}
