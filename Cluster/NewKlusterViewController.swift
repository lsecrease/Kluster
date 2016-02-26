//
//  NewKlusterViewController.swift
//  Cluster
//
//  Created by lsecrease on 10/25/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit
import Photos


class NewKlusterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundColorView: UIView!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var newKlusterTitleTextField: DesignableTextField!
    
    @IBOutlet weak var newKlusterDescriptionTextView: UITextView!
    @IBOutlet weak var newKlusterPlansTextView: UITextView!
    @IBOutlet weak var createNewKlusterButton: DesignableButton!
    @IBOutlet weak var selectFeaturedImageButton: DesignableButton!
    @IBOutlet weak var chooseLocationButton: DesignableButton!
    
    @IBOutlet var hideKeyboardInputAccessoryView: UIView!
    private var featuredImage: UIImage!
    private var klusterLocation: PFGeoPoint!
    
    @IBOutlet weak var chooseLocationPressed: DesignableButton!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        newKlusterTitleTextField.inputAccessoryView = hideKeyboardInputAccessoryView
        newKlusterDescriptionTextView.inputAccessoryView = hideKeyboardInputAccessoryView

        newKlusterTitleTextField.becomeFirstResponder()
        newKlusterTitleTextField.delegate = self
        newKlusterDescriptionTextView.delegate = self
        newKlusterPlansTextView.delegate = self
        
        // handle text view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    // MARK: - Text View Handler
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        let userInfo = notification.userInfo ?? [:]
        let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue().size
        
        self.newKlusterDescriptionTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        self.newKlusterDescriptionTextView.scrollIndicatorInsets = self.newKlusterDescriptionTextView.contentInset
        
        self.newKlusterPlansTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        self.newKlusterPlansTextView.scrollIndicatorInsets = self.newKlusterPlansTextView.contentInset

    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        self.newKlusterDescriptionTextView.contentInset = UIEdgeInsetsZero
        self.newKlusterDescriptionTextView.scrollIndicatorInsets = UIEdgeInsetsZero
        
        self.newKlusterPlansTextView.contentInset = UIEdgeInsetsZero
        self.newKlusterPlansTextView.scrollIndicatorInsets = UIEdgeInsetsZero
    }

    
    
    @IBAction func dismiss(sender: UIButton) {
        hideKeyboard()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func chooseLocationButtonClicked(sender: DesignableButton) {
        let actionSheet = UIAlertController.init(title: "Select Kluster Location", message: nil, preferredStyle: .ActionSheet)
        
        let currentLocationAction = UIAlertAction.init(title: "Current Location", style: .Default) { (action) -> Void in
            PFGeoPoint.geoPointForCurrentLocationInBackground({ (geoPoint, error) -> Void in
                if (error != nil) {
                    print("Error grabbing current location")
                    let alert = UIAlertController.init(title: "Error", message: "Unable to get your current location. Please try again.", preferredStyle: .Alert)
                    let ok = UIAlertAction.init(title: "Okay", style: .Default, handler: nil)
                    alert.addAction(ok)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    self.klusterLocation = geoPoint
                }
            })
        }
        
        actionSheet.addAction(currentLocationAction)
        
        let pickLocation = UIAlertAction.init(title: "Pick A Location", style: .Default) { (action) -> Void in
            let storyboard = UIStoryboard.init(name: "Map", bundle: nil)
            let mapController = storyboard.instantiateInitialViewController() as! UINavigationController
            // let locationController = mapController.childViewControllers.first as! LocationSelectViewController
            self.presentViewController(mapController, animated: true, completion: nil)
        }
        
        actionSheet.addAction(pickLocation)
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .Cancel) { (action) -> Void in
            actionSheet.dismissViewControllerAnimated(true, completion: nil)
        }
        
        actionSheet.addAction(cancelAction)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func selectFeaturedImageButtonClicked(sender: DesignableButton) {
        
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .NotDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                //self.pickFeaturedImageClicked(sender)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.selectFeaturedImageButtonClicked(sender)
                })
            })
            return
        }
        //Do you want to Take a Photo or Video with the Camera
        if authorization == .Authorized {
            let controller = ImagePickerSheetController()
            controller.addAction(ImageAction(title: NSLocalizedString("Take Photo or Video", comment: "ActionTitle"), secondaryTitle: NSLocalizedString("Use This One", comment: "ActionTitle"), handler: { (_) -> () in
                
                self.presentCamera()
                
                }, secondaryHandler: { (action, numberOfPhotos) -> () in
                    controller.getSelectedImagesWithCompletion({ (images) -> Void in
                        self.featuredImage = images[0]
                        self.backgroundImageView.image = self.featuredImage
                        self.backgroundColorView.alpha = 0.8
                    })
            }))
            
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"),  style: .Cancel))
            
            presentViewController(controller, animated: true, completion: nil)
            
        } else {
            // User has not authorized the camera
            self.promptForCameraAuthorization()
        }
    }
    
    
    func presentCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func promptForCameraAuthorization() {
        let alertController = UIAlertController.init(title: "Camera Access Denied", message: "Please allow Kluster to access your camera in the iOS Settings.", preferredStyle: UIAlertControllerStyle.Alert)
        let dismissAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(dismissAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    
    
    @IBAction func createNewKlusterButtonClicked(sender: DesignableButton) {
        
        
        if self.invalidTextData() {
            shakeTextField()
        } else if featuredImage == nil {
            shakePhotoButton()
        } else {
            //Create New Interest
            self.hideKeyboard()
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
            let title = newKlusterTitleTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let summary = newKlusterDescriptionTextView.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let plans = newKlusterPlansTextView.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            let imageData = KlusterImageResizer.resizeImageToWidth(featuredImage, width: 320)
            let base64String = imageData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            
            let params = ["title": title!,
                       "summary": summary!,
                         "plans": plans!,
                      "latitude": self.klusterLocation.latitude,
                     "longitude": self.klusterLocation.longitude,
                         "photo": base64String!]
            
            KlusterDataSource.createKlusterWithParams(params as [NSObject : AnyObject], completion: { (object, error) -> Void in
                if error != nil {
                    hud.removeFromSuperview()
                } else {
                    hud.removeFromSuperview()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        }
    }
    
    
    func shakeTextField() {
        newKlusterTitleTextField.animation = "shake"
        newKlusterTitleTextField.curve = "spring"
        newKlusterTitleTextField.duration = 1.0
        newKlusterTitleTextField.animate()
    }
    
    func shakePhotoButton() {
        selectFeaturedImageButton.animation = "shake"
        selectFeaturedImageButton.curve = "spring"
        selectFeaturedImageButton.duration = 1.2
        selectFeaturedImageButton.animate()
    }
    
    func invalidTextData() -> Bool {
        return newKlusterDescriptionTextView.text == "Describe Your New Kluster..." ||
            newKlusterTitleTextField.text!.isEmpty ||
            newKlusterDescriptionTextView.text.isEmpty
    }
    
    @IBAction func hideKeyboard() {
        if newKlusterDescriptionTextView.isFirstResponder() {
            newKlusterDescriptionTextView.resignFirstResponder()
        } else if newKlusterTitleTextField.isFirstResponder() {
            newKlusterTitleTextField.resignFirstResponder()
        } else if newKlusterPlansTextView.isFirstResponder() {
            newKlusterPlansTextView.resignFirstResponder()
        }

    }


}

// MARK: - UITextFieldDelegate
extension NewKlusterViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if newKlusterDescriptionTextView.text == "Describe Your New Kluster..." && !textField.text!.isEmpty {
            newKlusterDescriptionTextView.becomeFirstResponder()
        } else if newKlusterTitleTextField.text!.isEmpty {
            shakeTextField()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
}

extension NewKlusterViewController : UITextViewDelegate {
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        textView.text = ""
        return true
    }
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        if textView.text.isEmpty  {
            textView.text = "Describe Your Kluster..."
        }
        return true
    }
}

