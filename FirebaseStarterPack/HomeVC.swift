//
//  HomeVC.swift
//  FirebaseStarterPack
//
//  Created by Jake Jacobson on 8/26/16.
//  Copyright © 2016 JakeJacobson. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
import AVFoundation
import Photos

class HomeVC: UIViewController {

    @IBOutlet weak var signOutButton: FancyButton!
    @IBOutlet weak var previewView: UIView!
    //    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var countdownLabel: UILabel!
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var images = [UIImage]()
    
    var photoTimer = NSTimer()
    var countdownTimer = NSTimer()
    var flashTimer = NSTimer()
    var counter = 0
    var cCounter = 0
    var fCounter = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        signOutButton.enabled = false
        signOutButton.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        var frontCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        for device in devices {
            let device = device as! AVCaptureDevice
            if device.position == AVCaptureDevicePosition.Front {
                frontCamera = device
            }
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            if captureSession!.canAddInput(input) {
                captureSession!.addInput(input)
                
                stillImageOutput = AVCaptureStillImageOutput()
                stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                if captureSession!.canAddOutput(stillImageOutput) {
                    captureSession!.addOutput(stillImageOutput)
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                    previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                    previewView.layer.addSublayer(previewLayer!)
                    
                    captureSession!.startRunning()
                }
            }
        } catch {
            print("error?")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer!.frame = previewView.bounds
    }
    
    func signOut() {
        let keychainResult = KeychainWrapper.removeObjectForKey(KEY_UID)
        print("JAKE: ID removed from keychain \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegueWithIdentifier("goToSignIn", sender: nil)
    }

    @IBAction func signOutTapped(sender: FancyButton) {
        signOut()
    }


    @IBAction func photoButtonPressed(sender: RoundButton) {
        startCountdownTimer()
        delay(2.35) {
            self.startFlashTimer()
            self.startPhotoTimer()
        }
        delay(4) {
            let settings = RenderSettings()
            let imageAnimator = ImageAnimator(renderSettings: settings, images: self.transformArray(self.images))
            imageAnimator.render() {
                print("yes")
            }
            self.performSegueWithIdentifier("goToEmail", sender: nil)
        }
    }
    
    func delay(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            closure
        )
    }
    
    func startFlashTimer() {
        flashTimer.invalidate()
        fCounter = 1
        
        flash()
        print("start flash timer -startFlashTimer")
        flashTimer = NSTimer.scheduledTimerWithTimeInterval(0.175, target: self, selector: #selector(flashTimerAction), userInfo: nil, repeats: true)
    }
    
    func flashTimerAction() {
        flash()
        print("flashed \(fCounter)")
        
        if fCounter == 5 {
            flashTimer.invalidate()
        }
        fCounter += 1
    }
    
    func startPhotoTimer() {
        photoTimer.invalidate()
        counter = 1
        
        print("starting timer -startTimer")
        photoTimer = NSTimer.scheduledTimerWithTimeInterval(0.175, target: self, selector: #selector(photoTimerAction), userInfo: nil, repeats: true)
    }
    
    func photoTimerAction() {
        takePhoto()
        print("photo #\(counter) taken")
        
        if counter == 5 {
            photoTimer.invalidate()
            print("timer invalidated -timerAction")
            print(images)
        }
        counter += 1
    }
    
    func startCountdownTimer() {
        countdownTimer.invalidate()
        cCounter = 3
        print("starting countdown -startCountdownTimer")
        countdownLabel.hidden = false
        countdownLabel.text = String(cCounter)
    
        countdownTimer = NSTimer.scheduledTimerWithTimeInterval(0.75, target: self, selector: #selector(countdownTimerAction), userInfo: nil, repeats: true)
    }
    
    func countdownTimerAction() {
        
        print("\(cCounter) -countdownAction")
        
        if cCounter == 1 {
            countdownTimer.invalidate()
            countdownLabel.hidden = true
            cCounter = 3
        }
        cCounter -= 1
        countdownLabel.text = String(cCounter)
    }

    func flash() {
        if let wnd = self.view{
            
            let v = UIView(frame: wnd.bounds)
            v.backgroundColor = UIColor.whiteColor()
            v.alpha = 1
            
            wnd.addSubview(v)
            UIView.animateWithDuration(0.1, animations: {
                v.alpha = 0.0
                }, completion: {(finished:Bool) in
                    print("inside")
                    v.removeFromSuperview()
            })
        }
    }
    
    func takePhoto() {
        //need to disable touch
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)//
                    self.images.append(image)
                    //self.capturedImage.image = image
                }
            })
        }
        //re enable touch
    }
 
    func transformArray(array: [UIImage]) -> [UIImage] {
        var arrayCopy = array
        arrayCopy = arrayCopy.reverse()
        arrayCopy.removeAtIndex(0)
        let mergedArray = array + arrayCopy
        let mergedTwo = mergedArray
        let mergedThree = mergedArray
        let mergedFour = mergedArray
        let finalMerge = mergedArray + mergedTwo + mergedThree + mergedFour
        
        return finalMerge
    }
    
    }