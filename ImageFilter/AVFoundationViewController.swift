//
//  AVFoundationViewController.swift
//  ImageFilter
//
//  Created by Dan Hoang on 8/10/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

//
//  ViewController.swift
//  UseAVFoundation
//
//  Created by Dan Hoang on 8/8/14.
//  Copyright (c) 2014 Dan Hoang. All rights reserved.
//

import UIKit
import AVFoundation
import CoreVideo
import ImageIO
import QuartzCore
import CoreMedia

class AVFoundationViewController: UIViewController {
    
    //used for capturing a photo from AVCaptureSession
    var stillImageOutput = AVCaptureStillImageOutput()
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var innerView: UIView!
    
    @IBOutlet var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //keep hidden until user takes photo
        saveButton.hidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //create a capture session
        var captureSession = AVCaptureSession()
        //instruct the capture session
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        //lower preset when you don’t want much data.
        //setup preview layer
        //var layer = self.view.layer
        var layer = self.innerView.layer
        
        var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        println(self.view.bounds)
        //previewLayer.frame = self.view.bounds
        previewLayer.frame = self.innerView.bounds
        //self.view.layer.addSublayer(previewLayer)
        self.innerView.layer.addSublayer(previewLayer)
        
        var device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error : NSError?
        var input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as AVCaptureDeviceInput!
        //but now it’s trying to generate an input device that doesn’t exist in simulator.
        
        if error != nil {
            //will print error if creating the input device does not work, IE simulator
            println(error!.localizedDescription)
        }
        else {
            captureSession.addInput(input)
            
            //create ouput
            var outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            self.stillImageOutput.outputSettings = outputSettings
            captureSession.addOutput(self.stillImageOutput)
            captureSession.startRunning()
        }
    }
    
    @IBAction func takePhotoPressed(sender: AnyObject) {
        
        var videoConnection : AVCaptureConnection?
        
        for connection in self.stillImageOutput.connections {
            
            if let cameraConnection = connection as? AVCaptureConnection {
                for port in cameraConnection.inputPorts {
                    if let videoPort = port as? AVCaptureInputPort {
                        
                        if videoPort.mediaType == AVMediaTypeVideo {
                            videoConnection = cameraConnection
                        }
                    }
                }
                
            }
            
        }
        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (buffer, error) -> Void in
            
            //    if let dict = CMGetAttachment(buffer, kCGImagePropertyExifDictionary, nil) as? Unmanaged<CFDictionaryRef> {
            //
            //    }
            
            var data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            var image = UIImage(data: data)
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.imageView.image = image
            })
            
        })
        self.saveButton.hidden = false
    }
    
    @IBAction func savePhotoPressed(sender: AnyObject) {
        let initView = self.storyboard.instantiateViewControllerWithIdentifier("initialView") as ViewController
        initView.currentImage = self.imageView.image
        self.navigationController.pushViewController(initView, animated: true)
    }
    
    
    
}