//
//  ViewController.swift
//  ImageFilter
//
//  Created by Dan Hoang on 8/4/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let photoPicker = UIImagePickerController()
    let cameraPicker = UIImagePickerController()
    var imageViewSize : CGSize!
    //this is an alertView:
    let alertPopUp = UIAlertController(title: "Alert!", message: "stop", preferredStyle: UIAlertControllerStyle.Alert)
    //let actionController = UIAlertController(title: "Title", message: "message", preferredStyle: UIAlertControllerStyle.ActionSheet)

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.borderWidth = 4
        imageView.layer.borderColor = UIColor.greenColor().CGColor
        //set to photo library:
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            self.cameraPicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.cameraPicker.allowsEditing = true
            self.cameraPicker.delegate = self
        }
        else {
            //point out that camera is not enabled.
            var alert: UIAlertView = UIAlertView()
            alert.title = "No camera."
            alert.message = "This device does not have a camera."
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
        self.photoPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.photoPicker.allowsEditing = true //forces the edit
        self.photoPicker.delegate = self
        
        NSUserDefaults.standardUserDefaults().synchronize()
        if let isNew = NSUserDefaults.standardUserDefaults().valueForKey("newUser") as? Bool {
            var alert: UIAlertView = UIAlertView()
            alert.title = "Welcome!"
            alert.message = "Your first time here? We will ask for photo permission."
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
        else {
            println("Not their first time here.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //why use lazy?
    lazy var actionController : UIAlertController = {
        var actionController = UIAlertController(title: "Select", message: "Do you want to use camera or photo library?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        //some actions to the controller.
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            //present the camera picker
            self.presentViewController(self.cameraPicker, animated: true, completion: nil)
            })
        let photoAction = UIAlertAction(title: "Library", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            self.presentViewController(self.photoPicker, animated: true, completion: nil)
            })
        actionController.addAction(cameraAction)
        actionController.addAction(photoAction)
        return actionController
    }()
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        let editedImage = info[UIImagePickerControllerEditedImage] as UIImage
        self.imageView.image = editedImage
        self.dismissViewControllerAnimated(true, completion: nil)
        editedImage.CIImage
    }
    
    @IBAction func handlePhotoButtonPressed(sender: AnyObject) {
        self.presentViewController(self.actionController, animated: true, completion: nil)
    }
    @IBAction func photoTapped(sender: AnyObject) {
        self.presentViewController(self.cameraPicker, animated: true, completion: nil)
    }
    
    //ensures canceling does not freeze
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        println("user canceled")
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

