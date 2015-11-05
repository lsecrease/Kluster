//
//  LoginViewController.swift
//  Cluster
//
//  Created by Michael Fellows on 10/29/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBAction func loginWithFacebookPressed(sender: AnyObject) {
        
        let permissions = ["email", "public_profile", "user_friends"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                
                let shouldMakeFacebookRequest: Bool = (user.isNew || user.objectForKey("firstName") == nil)
                if  shouldMakeFacebookRequest {
                    print("User signed up and logged in through Facebook!")
                    
                    // Make graph request for current user and get their information
                    let params = ["fields" : "first_name, last_name, email, name, id, picture"]
                    
                    let request: FBSDKGraphRequest = FBSDKGraphRequest.init(graphPath: "me", parameters: params, HTTPMethod: "GET")
                    request.startWithCompletionHandler({ (connection: FBSDKGraphRequestConnection!, result: AnyObject?, graphRequestError: NSError?) -> Void in
                        if let result = result {
                            print(result)
                            
                            let dict: NSDictionary! = result as! NSDictionary
                            user.setObject(dict["first_name"]!, forKey: "firstName")
                            user.setObject(dict["last_name"]!, forKey: "lastName")
                            user.email = dict["email"]! as? String
                            user.setObject(dict["id"]!, forKey: "facebookId")
                            
                            // Get the data for the user's facebook photo
                            let avatarUrlString: String = dict.valueForKeyPath("picture.data.url") as! String
                            let imageData = NSData(contentsOfURL: NSURL(string: avatarUrlString)!) // NSData(contentsOfFile: avatarUrlString)
                            let file: PFFile = PFFile.init(name: "avatar.png", data: imageData!)
                            user.setObject(file, forKey: "avatar")
                            user.saveInBackgroundWithBlock({ (succeed: Bool, saveError: NSError?) -> Void in
                                if let saveError = saveError {
                                    // Error saving the user.. 
                                    self.showAlertWithMessage(saveError.localizedDescription)
                                } else {
                                    // Successfully signed in a new user
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                }
                            })
                        } else {
                            print("Error getting information from facebook. Unable to let the user sign in.")
                            if let graphRequestError = graphRequestError {
                                self.showAlertWithMessage(graphRequestError.localizedDescription)
                            } else {
                                self.showAlertWithMessage("Something went wrong when logging in with Facebook.")
                            }
                        }
                    })
                } else {
                    // Successful login
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                if let error = error {
                    self.showAlertWithMessage(error.localizedDescription)
                } else {
                    print("User cancelled Facebook login.")
                }
            }
        }
    }
    
    private func showAlertWithMessage(message: String) {
        let controller: UIAlertController = UIAlertController.init(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let dismiss: UIAlertAction = UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil)
        controller.addAction(dismiss)
        self.presentViewController(controller, animated: true, completion: nil)
    }
}
