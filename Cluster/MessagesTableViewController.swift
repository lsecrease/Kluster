//
//  MessagesTableViewController.swift
//  Cluster
//
//  Created by lsecrease on 10/21/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class MessagesTableViewController: UITableViewController {
    
    var parentNavigationController : UINavigationController?
    
    var shouldContinueFetchingMessages: Bool = true
    var queryLimit = 20
    var kluster: Kluster!
    var textView: MessageTextView!
    let textViewHeight = 60.0 as CGFloat
    var messages = [PFObject]()
    let windowHeight: CGFloat? = UIApplication.shared.keyWindow?.frame.size.height
    
    //MARK: - Change Status Bar to White
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        
        // Set dynamic row height
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 68.0
        
        // Format the navigation bar
        self.navigationItem.title = self.kluster.title
        
        let dismissItem = UIBarButtonItem.init(image: UIImage(named: "CloseButton2"),
            style: .plain,
            target: self,
            action: #selector(MessagesTableViewController.dismissPressed(_:)))
        self.navigationItem.leftBarButtonItem = dismissItem
        
//        var groupImageView = PFImageView()
//        groupImageView.frame = CGRectMake(0, 0, 36.0, 36.0)
//        groupImageView.file = self.kluster.featuredImageFile
//        groupImageView.backgroundColor = .redColor()
//        var menuItem = UIBarButtonItem(customView: groupImageView)
        let menuItem = UIBarButtonItem.init(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(MessagesTableViewController.menuPressed(_:)))
        self.navigationItem.rightBarButtonItem = menuItem
//        
//        groupImageView.loadInBackground()
        
        self.fetchMessages()

        // Update the keyboard status
        self.textView = MessageTextView.init(frame: self.originalFrame())
        self.textView.sendButton.addTarget(self, action: #selector(MessagesTableViewController.sendPressed(_:)), for: .touchUpInside)
        UIApplication.shared.keyWindow?.addSubview(self.textView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesTableViewController.keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesTableViewController.keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Bit of a hack below. PageViewController prevents ViewWillAppear from being called on the initial load
        self.textView.frame = self.originalFrame()
        UIApplication.shared.keyWindow?.addSubview(self.textView)
        
        self.fetchMessages()
    }
    
    func dismissPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func menuPressed(_ sender: UIBarButtonItem) {
        let popover = PopoverMenuController()
        popover.kluster = self.kluster
        let messageNavController = MessagesNavigationController.init(rootViewController: popover)
        messageNavController.modalPresentationStyle = UIModalPresentationStyle.custom
        self.present(messageNavController, animated: false, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.textView.frame = self.originalFrame()
        self.textView.removeFromSuperview()
    }
    
    func sendPressed(_ sender: UIButton) {
        let text = self.textView.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
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
    
    fileprivate func fetchMessages() {
        KlusterDataSource.fetchMessagesInKluster(self.kluster.id, skip: 0) { (objects, error) -> Void in
            if (error != nil) {
                print("Error fetching messages.")
            } else {
                self.shouldContinueFetchingMessages = (objects as AnyObject).count >= 20
                self.messages = objects as! [PFObject]
//                let newMessages = objects as! [PFObject]
//                self.messages = newMessages.reverse() + self.messages
                
                self.messages = self.messages.reversed()
                
                self.tableView.reloadData()
                
                // Scroll to the last index path...
                self.scrollTableToBottom(false)
            }
        }
    }

    
    fileprivate func originalFrame() -> CGRect {
        let y = UIApplication.shared.keyWindow!.frame.size.height - textViewHeight //  + 190.0
        return CGRect(x: 0, y: y, width: self.view.frame.size.width, height: textViewHeight)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! MessageTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
        
        let message = Message.init(object: self.messages[indexPath.row])
        let user = message.user
        
        cell.messageLabel.text = message.text
        
        let firstName = user?.object(forKey: "firstName") as! String
        let lastName = user?.object(forKey: "lastName") as! String
        // Configure the cell...
        cell.nameLabel.text = firstName + " " + lastName
        
        cell.avatarImageView.image = nil
        cell.avatarImageView.tag = indexPath.row
        cell.avatarImageView.isUserInteractionEnabled = true
        cell.avatarImageView.file = user?.object(forKey: "avatarThumbnail") as? PFFile
        cell.avatarImageView.loadInBackground()
        cell.selectionStyle = .none
        
        // Add a tap recognizer to the cell
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(MessagesTableViewController.avatarTapped(_:)))
        cell.avatarImageView.addGestureRecognizer(tapRecognizer)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return textViewHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.textView.textField.resignFirstResponder()
    }
    
    // MARK: - Notifications
    
    func keyboardWillShowNotification(_ notification: Notification) {
        updateBottomLayoutConstraintWithNotification(notification, hide: false)
    }
    
    func keyboardWillHideNotification(_ notification: Notification) {
        updateBottomLayoutConstraintWithNotification(notification, hide: true)
    }
    
    // MARK: - Selector
    
    func avatarTapped(_ sender: UITapGestureRecognizer) {
        let message = Message.init(object: self.messages[sender.view!.tag])
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let profileViewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileViewController.user = message.user
        self.present(profileViewController, animated: true, completion: nil)
    }
    
    
    // MARK: - Private
    
    func updateBottomLayoutConstraintWithNotification(_ notification: Notification, hide: Bool) {
        let userInfo = notification.userInfo!
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        let rawAnimationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
        
        print("Converted keyboard end frame height: %f", convertedKeyboardEndFrame.size.height)
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: animationCurve, animations: { () -> Void in
            var frame = self.textView.frame
            if (hide) {
                // Bring the textView back to it's original frame
                self.textView.frame = self.originalFrame()
            } else {
                frame.origin.y =  self.windowHeight! - convertedKeyboardEndFrame.size.height - self.textViewHeight
                self.textView.frame = frame
            }
        }) { (completed) -> Void in
                self.scrollTableToBottom(true)
        }
    }
    
    fileprivate func scrollTableToBottom(_ animated: Bool) {
        if (self.messages.count > 0) {
            let indexToScrollTo = Int(self.messages.count - 1)
            let lastIndexPath = IndexPath.init(item: indexToScrollTo, section: 0)
            self.tableView.scrollToRow(at: lastIndexPath, at: .top, animated: animated)
        }
    }
}

extension MessagesTableViewController : DZNEmptyDataSetDelegate {
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        self.textView.textField.becomeFirstResponder()
    }
}

extension MessagesTableViewController : DZNEmptyDataSetSource {
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "It's a little too quiet in here."
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        
        let attributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 17.0),
            NSParagraphStyleAttributeName : paragraph]
        let attributedString = NSAttributedString.init(string: text, attributes: attributes)
        return attributedString
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Crickets..."
        let attributes = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 19.0),
            NSForegroundColorAttributeName: UIColor.darkGray]
        let attributedString = NSAttributedString.init(string: text, attributes: attributes)
        return attributedString
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let text = "Say something"
        let attributes = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 19.0),
            NSForegroundColorAttributeName: UIColor.klusterPurpleColor()]
        let attributedString = NSAttributedString.init(string: text, attributes: attributes)
        return attributedString
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 20.0
    }
}

