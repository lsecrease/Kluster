//
//  NewKlusterViewController.swift
//  Cluster
//
//  Created by lsecrease on 10/25/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit
import Photos
import Spring
import MBProgressHUD



class NewKlusterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundColorView: UIView!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet var newKlusterTitleTextField: DesignableTextField!
    
    @IBOutlet weak var newKlusterDescriptionTextView: UITextView!
    @IBOutlet weak var newKlusterPlansTextView: UITextView!
    @IBOutlet weak var createNewKlusterButton: DesignableButton!
    @IBOutlet weak var selectFeaturedImageButton: DesignableButton!
    @IBOutlet weak var chooseLocationButton: DesignableButton!
    
    @IBOutlet var hideKeyboardInputAccessoryView: UIView!
    fileprivate var featuredImage: UIImage!
    fileprivate var klusterLocation: PFGeoPoint!
    
    @IBOutlet weak var chooseLocationPressed: DesignableButton!
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
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
        NotificationCenter.default.addObserver(self, selector: #selector(NewKlusterViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewKlusterViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    // MARK: - Text View Handler
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(_ notification: Notification)
    {
        let userInfo = notification.userInfo ?? [:]
        let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        
        self.newKlusterDescriptionTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        self.newKlusterDescriptionTextView.scrollIndicatorInsets = self.newKlusterDescriptionTextView.contentInset
        
        self.newKlusterPlansTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        self.newKlusterPlansTextView.scrollIndicatorInsets = self.newKlusterPlansTextView.contentInset

    }
    
    func keyboardWillHide(_ notification: Notification)
    {
        self.newKlusterDescriptionTextView.contentInset = UIEdgeInsets.zero
        self.newKlusterDescriptionTextView.scrollIndicatorInsets = UIEdgeInsets.zero
        
        self.newKlusterPlansTextView.contentInset = UIEdgeInsets.zero
        self.newKlusterPlansTextView.scrollIndicatorInsets = UIEdgeInsets.zero
    }

    
    
    @IBAction func dismiss(_ sender: UIButton) {
        hideKeyboard()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func chooseLocationButtonClicked(_ sender: DesignableButton) {
        let actionSheet = UIAlertController.init(title: "Select Kluster Location", message: nil, preferredStyle: .actionSheet)
        
        let currentLocationAction = UIAlertAction.init(title: "Current Location", style: .default) { (action) -> Void in
            PFGeoPoint.geoPointForCurrentLocation(inBackground: { (geoPoint, error) -> Void in
                if (error != nil) {
                    print("Error grabbing current location")
                    let alert = UIAlertController.init(title: "Error", message: "Unable to get your current location. Please try again.", preferredStyle: .alert)
                    let ok = UIAlertAction.init(title: "Okay", style: .default, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.klusterLocation = geoPoint
                }
            })
        }
        
        actionSheet.addAction(currentLocationAction)
        
        let pickLocation = UIAlertAction.init(title: "Pick A Location", style: .default) { (action) -> Void in
            let storyboard = UIStoryboard.init(name: "Map", bundle: nil)
            let mapController = storyboard.instantiateInitialViewController() as! UINavigationController
            let locationController = mapController.childViewControllers.first as! LocationSelectViewController
            locationController.completion = { geoPoint in
                self.klusterLocation = geoPoint
            }
            
            self.present(mapController, animated: true, completion: nil)
        }
        
        actionSheet.addAction(pickLocation)
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) -> Void in
            actionSheet.dismiss(animated: true, completion: nil)
        }
        
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func selectFeaturedImageButtonClicked(_ sender: DesignableButton) {
        
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                //self.pickFeaturedImageClicked(sender)
                DispatchQueue.main.async(execute: { () -> Void in
                    self.selectFeaturedImageButtonClicked(sender)
                })
            })
            return
        }
        //Do you want to Take a Photo or Video with the Camera
        if authorization == .authorized {
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
            
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"),  style: .cancel))
            
            present(controller, animated: true, completion: nil)
            
        } else {
            // User has not authorized the camera
            self.promptForCameraAuthorization()
        }
    }
    
    
    func presentCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func promptForCameraAuthorization() {
        let alertController = UIAlertController.init(title: "Camera Access Denied", message: "Please allow Kluster to access your camera in the iOS Settings.", preferredStyle: UIAlertControllerStyle.alert)
        let dismissAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }

    
    
    @IBAction func createNewKlusterButtonClicked(_ sender: DesignableButton) {
        
        
        if self.invalidTextData() {
            shakeTextField()
        } else if featuredImage == nil {
            shakePhotoButton()
        } else {
            //Create New Interest
            self.hideKeyboard()
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            
            let title = newKlusterTitleTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let summary = newKlusterDescriptionTextView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let plans = newKlusterPlansTextView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            let imageData = KlusterImageResizer.resizeImageToWidth(featuredImage, width: 320)
            let base64String = imageData?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
            
            let params = ["title": title!,
                       "summary": summary!,
                         "plans": plans!,
                      "latitude": self.klusterLocation.latitude,
                     "longitude": self.klusterLocation.longitude,
                         "photo": base64String!] as [String : Any]
            
            KlusterDataSource.createKlusterWithParams(params as [AnyHashable: Any], completion: { (object, error) -> Void in
                if error != nil {
                    hud?.removeFromSuperview()
                } else {
                    hud?.removeFromSuperview()
                    self.dismiss(animated: true, completion: nil)
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
        if newKlusterDescriptionTextView.isFirstResponder {
            newKlusterDescriptionTextView.resignFirstResponder()
        } else if newKlusterTitleTextField.isFirstResponder {
            newKlusterTitleTextField.resignFirstResponder()
        } else if newKlusterPlansTextView.isFirstResponder {
            newKlusterPlansTextView.resignFirstResponder()
        }

    }


}

// MARK: - UITextFieldDelegate
extension NewKlusterViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.text = ""
        return true
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text.isEmpty  {
            textView.text = "Describe Your Kluster..."
        }
        return true
    }
}

