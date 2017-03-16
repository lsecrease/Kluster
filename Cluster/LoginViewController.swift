//
//  LoginViewController.swift
//  Cluster
//
//  Created by Michael Fellows on 10/29/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4
import Parse
import ParseUI

class LoginViewController: UIViewController {
    
    @IBAction func loginWithFacebookPressed(_ sender: AnyObject) {

//        let permissions = ["email", "public_profile", "user_friends"]
//        PFFacebookUtils.logInInBackground(withReadPermissions: permissions) { (user: PFUser?, error: Error?) -> Void in
//            if let user = user {
//                let shouldMakeFacebookRequest: Bool = (user.isNew || user.object(forKey: "firstName") == nil || user.object(forKey: "lastName") == nil)
//                
//                if shouldMakeFacebookRequest {
//                    print("User signed up and logged in through Facebook!")
//                    
//                    // Make graph request for current user and get their information
//                    // user_location, user_birthday, user_about_me
//                    let params = ["fields" : "first_name, last_name, email, name, id, picture"]
//                    
//                    let request: FBSDKGraphRequest = FBSDKGraphRequest.init(graphPath: "me", parameters: params, httpMethod: "GET")
//                    request.start(completionHandler: { (connection: FBSDKGraphRequestConnection?, result: Any?, graphRequestError: Error?) -> Void in
//                        if let result = result {
//                            print(result)
//                            
//                            let dict: NSDictionary! = result as! NSDictionary
//                            user.setObject(dict["first_name"]!, forKey: "firstName")
//                            user.setObject(dict["last_name"]!, forKey: "lastName")
//                            user.email = dict["email"]! as? String
//                            user.setObject(dict["id"]!, forKey: "facebookId")
//                            
//                            // Get the data for the user's facebook photo
//                            let avatarUrlString: String = dict.value(forKeyPath: "picture.data.url") as! String
//                            let imageData = try? Data(contentsOf: URL(string: avatarUrlString)!) // NSData(contentsOfFile: avatarUrlString)
//                            let file = PFFile.init(name: "avatar.png", data: imageData!)
//                            user.setObject(file!, forKey: "avatar")
//                            user.saveInBackground(block: { (succeed: Bool, saveError: Error?) -> Void in
//                                if let saveError = saveError {
//                                    // Error saving the user..
//                                    self.showAlertWithMessage(saveError.localizedDescription)
//                                } else {
//                                    // Successfully signed in a new user
//                                    self.goToMainMenu()
//                                }
//                            })
//                        } else {
//                            print("Error getting information from facebook. Unable to let the user sign in.")
//                            if let graphRequestError = graphRequestError {
//                                self.showAlertWithMessage(graphRequestError.localizedDescription)
//                            } else {
//                                self.showAlertWithMessage("Something went wrong when logging in with Facebook.")
//                            }
//                        }
//                    })
//                } else {
//                    // Successful login
//                    self.goToMainMenu()
//                }
//            } else {
//                if let error = error {
//                    self.showAlertWithMessage(error.localizedDescription)
//                } else {
//                    print("User cancelled Facebook login.")
//                }
//            }
//            
//        }
        
        self.goToMainMenu()
    }
    
    fileprivate func goToMainMenu() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let home = storyboard.instantiateInitialViewController() as! HomeViewController
        UIApplication.shared.keyWindow?.rootViewController = home
    }
    
    fileprivate func showAlertWithMessage(_ message: String) {
        let controller: UIAlertController = UIAlertController.init(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let dismiss: UIAlertAction = UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil)
        controller.addAction(dismiss)
        self.present(controller, animated: true, completion: nil)
    }
}






































