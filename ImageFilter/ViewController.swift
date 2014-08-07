//
//  ViewController.swift
//  ImageFilter
//
//  Created by Dan Hoang on 8/4/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate , PhotoSelectedDelegate {
    let photoPicker = UIImagePickerController()
    let cameraPicker = UIImagePickerController()
    var imageViewSize : CGSize!
    //this is an alertView:
    let alertPopUp = UIAlertController(title: "Alert!", message: "stop", preferredStyle: UIAlertControllerStyle.Alert)
    //let actionController = UIAlertController(title: "Title", message: "message", preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    var collectionsFetchResults = [PHFetchResult]()
    var collectionsLocalizedTitles = [String]()
    var selectedAsset : PHAsset?
    let adjustmentFormatterIndentifier = "com.imagefilter.dan"
    var context = CIContext(options: nil)

    var cameraWorks = true
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    var filterName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.imageViewSize = self.imageView.frame.size

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
            var cameraWorks = false
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
            println("Not the first time here.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "ShowGrid" {
            
            let gridVC = segue.destinationViewController as GridViewController
            //fetching all assets without any options - gives us all the users photos
            
            gridVC.assetsFetchResult = PHAsset.fetchAssetsWithOptions(nil)
            gridVC.delegate = self
        }
        //self.checkAuthentication()
    }
func checkAuthentication(completionHandler: (PHAuthorizationStatus -> Void)) -> Void {
    switch PHPhotoLibrary.authorizationStatus() {
    case .NotDetermined:
        println("Not Determined")
    PHPhotoLibrary.requestAuthorization({(status: PHAuthorizationStatus) -> Void in
        completionHandler(status)
    })
    //something else restricts them
    default:
        println("Restricted")
//    case .Denied:
//        println("Denied")
//    case .Authorized:
//        println("Authorized")
//        isAuthorized = true
    }
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

    lazy var actionControllerFilter : UIAlertController = {
        var actionControllerFilter = UIAlertController(title: "Select", message: "What kind of filter do you want to use?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        //some actions to the controller.
        let sepiaAction = UIAlertAction(title: "Sepia", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            //do the sepia
                println("time to do sepia")
                self.filterName = "CISepiaTone"
                self.doFilter()
            })
        let colorInvertAction = UIAlertAction(title: "SixfoldRefl", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            //do the sepia
                println("time to do sepia")
                self.filterName = "CIColorInvert"
                self.doFilter()
            })
        let vignetteAction = UIAlertAction(title: "vignette", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            //do the sepia
                println("time to do sepia")
                self.filterName = "CIVignette"
                self.doFilter()
            })
        let colorMonochromeAction = UIAlertAction(title: "monochrome", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            //do the sepia
                println("time to do sepia")
                self.filterName = "CIColorMonochrome"
                self.doFilter()
            })
        actionControllerFilter.addAction(sepiaAction)
        actionControllerFilter.addAction(colorInvertAction)
        actionControllerFilter.addAction(vignetteAction)
        actionControllerFilter.addAction(colorMonochromeAction)
        return actionControllerFilter
    }()
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true) {

            let editedImage = info[UIImagePickerControllerEditedImage] as UIImage
            self.imageView.image = editedImage
        }
    }

    func photoSelected(asset : PHAsset) -> Void {
        //selectedAsset is now set, enabling the filter button
        self.selectedAsset = asset
        self.updateImage()
        
    }
    
    @IBAction func handlePhotoButtonPressed(sender: AnyObject) {

    }
    
    @IBAction func filterPressed(sender: AnyObject) {
        println("about to present controller: ")
        if self.actionControllerFilter.popoverPresentationController {
        println("did get in here")
//if it exists, i give it the filterbutton's view.
        self.actionControllerFilter.popoverPresentationController.sourceView = filterButton
}
        self.presentViewController(self.actionControllerFilter, animated: true, completion: nil)
        
        
    
    }
    
    @IBAction func photoTapped(sender: AnyObject) {
        self.presentViewController(self.cameraPicker, animated: true, completion: nil)
    }
    
    func doFilter() {
        //but that doesn't work now, so check for pop-over property.
        var options = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = {(data : PHAdjustmentData!) -> Bool in
            //the name we just gave.
            return data.formatIdentifier == self.adjustmentFormatterIndentifier && data.formatVersion == "1.0"
}
            //so others don't get access to our adjustments
        if self.selectedAsset != nil {
            self.selectedAsset!.requestContentEditingInputWithOptions(options, completionHandler: { ( contentEditingInput : PHContentEditingInput!, info : [NSObject : AnyObject]!) -> Void in
                
                //grabbing the image and converting it to CIImage
                //now grab the url to that spot.
                var url = contentEditingInput.fullSizeImageURL
                var orientation = contentEditingInput.fullSizeImageOrientation
                var inputImage = CIImage(contentsOfURL: url)
                inputImage = inputImage.imageByApplyingOrientation(orientation)
                
                //creating the filter
println("Doing Filter")
                var curFilterName = self.filterName //"CISepiaTone"
                var filter = CIFilter(name: curFilterName)
                //filter = CIFilter(name: "CISepiaTone")
                filter.setDefaults()
                filter.setValue(inputImage, forKey: kCIInputImageKey)
                var outputImage = filter.outputImage
                
                var cgimg = self.context.createCGImage(outputImage, fromRect: outputImage.extent())
                var finalImage = UIImage(CGImage: cgimg)
                //now set the image
                var jpegData = UIImageJPEGRepresentation(finalImage, 1.0)
                
                //create our adjustmentdata
                var adjustmentData = PHAdjustmentData(formatIdentifier: self.adjustmentFormatterIndentifier, formatVersion: "1.0", data: jpegData)
                var contentEditingOutput = PHContentEditingOutput(contentEditingInput:contentEditingInput)
                //CUTOFF to where it works:
                println(contentEditingOutput.renderedContentURL)
                jpegData.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)
                contentEditingOutput.adjustmentData = adjustmentData
                
                //requesting the change
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    //change block
                    var request = PHAssetChangeRequest(forAsset: self.selectedAsset)
                    request.contentEditingOutput = contentEditingOutput
                    
                    }, completionHandler: { (success : Bool,error : NSError!) -> Void in
                        //completionHandler for the change
                        if !success {
                            println(error.localizedDescription)
                        }
                        else {
                            //for the time being, 10 sec. delay, background thread.
                            self.imageView.image = finalImage
                        }
                })
            })
        }
        println("got to the not doing")
}

    //ensures canceling does not freeze
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        println("user canceled")
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    func updateImage() {
        
        var targetSize = self.imageView.frame.size
        PHImageManager.defaultManager().requestImageForAsset(self.selectedAsset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (result : UIImage!, info : [NSObject : AnyObject]!) -> Void in
            self.imageView.image = result
        }
        
    }
    //when something is added to library
    func photoLibraryDidChange(changeInstance: PHChange!) {
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            
            if self.selectedAsset != nil {
                var changeDetails = changeInstance.changeDetailsForObject(self.selectedAsset)
                if changeDetails != nil {
                    self.selectedAsset = changeDetails.objectAfterChanges as? PHAsset
                    
                    if changeDetails.assetContentChanged {
                        
                        self.updateImage()
                        
                    }
                    
                }
            }
        }
    }

}

