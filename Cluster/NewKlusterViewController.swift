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
            
        }
        

    }
    
    
    func presentCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    
    
    @IBAction func createNewKlusterButtonClicked(sender: DesignableButton) {
        
        if newKlusterDescriptionTextView.text == "Describe Your New Kluster..." || newKlusterTitleTextField.text!.isEmpty {
            shakeTextField()
        } else if featuredImage == nil {
            shakePhotoButton()
        } else {
            //Create New Interest
            self.hideKeyboard()
            self.dismissViewControllerAnimated(true, completion: nil)
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

