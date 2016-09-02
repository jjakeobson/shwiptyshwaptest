//
//  EmailVC.swift
//  FirebaseStarterPack
//
//  Created by Jake Jacobson on 8/29/16.
//  Copyright © 2016 JakeJacobson. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import NotificationCenter
import SwiftKeychainWrapper
import MessageUI

class EmailVC: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var receipientFieldOne: FancyField!
    var delimiter = "."
    var settings = RenderSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    @IBAction func sendEmailTapped(sender: FancyButton) {
        if let email = receipientFieldOne.text {
            sendEmail(email, videoPath: settings.outputURL)
            completeSendEmail()
            performSegueWithIdentifier("restartLoop", sender: nil)
            wipeCache()
        }
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
            else {
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
            else {
                
            }
        }
    }
    
    func completeSendEmail() {
        let email = receipientFieldOne.text!
        var username = email.componentsSeparatedByString(delimiter)
        let customerData = ["email" : email]
        if let currentStore = FIRAuth.auth()?.currentUser {
            let sid = currentStore.uid
            let cidTrue = [username[0] : "true"]
            let sidTrue = [sid : "true"]
            DataService.ds.linkEmUp(username[0], sid: sid, cidTrue: cidTrue, sidTrue: sidTrue, cData: customerData)
        }
    }
    
    func sendEmail(email: String, videoPath: NSURL) {
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = "fotomitest@gmail.com"
        smtpSession.password = "letsmakemillions"
        smtpSession.port = 465
        smtpSession.authType = MCOAuthType.SASLPlain
        smtpSession.connectionType = MCOConnectionType.TLS
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding){
                    NSLog("Connectionlogger: \(string)")
                }
            }
        }
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: "Customer", mailbox: email)]
        builder.header.from = MCOAddress(displayName: "FotoMi!", mailbox: "FotoMi")
        builder.header.subject = "Thanks for using FotoMi!"
        builder.htmlBody = "Greetings Alex, are you ready to be millionaires?!"
        
        var dataImage: NSData?
        dataImage = NSData(contentsOfURL: videoPath)
        let attachment = MCOAttachment()
        attachment.mimeType =  "video/mp4"
        attachment.filename = "video.mp4"
        attachment.data = dataImage
        builder.addAttachment(attachment)
        
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperationWithData(rfc822Data)
        sendOperation.start { (error) -> Void in
            if (error != nil) {
                NSLog("Error sending email: \(error)")
            } else {
                NSLog("Successfully sent email!")
            }
        }
    }
    
    func wipeCache() {
        
        let fileManager = NSFileManager.defaultManager()
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first! as NSURL
        let documentsPath = documentsUrl.path
        
        do {
            if let documentPath = documentsPath
            {
                let fileNames = try fileManager.contentsOfDirectoryAtPath("\(documentPath)")
                print("all files in cache: \(fileNames)")
                for fileName in fileNames {
                    
                    if (fileName.hasSuffix(".mp4"))
                    {
                        let filePathName = "\(documentPath)/\(fileName)"
                        try fileManager.removeItemAtPath(filePathName)
                    }
                }
                
                let files = try fileManager.contentsOfDirectoryAtPath("\(documentPath)")
                print("all files in cache after deleting images: \(files)")
            }
            
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }

}
