//
//  ViewController.swift
//  FirebaseStarterPack
//
//  Created by Jake Jacobson on 8/25/16.
//  Copyright © 2016 JakeJacobson. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import NotificationCenter

class LoginVC: UIViewController {

    @IBOutlet weak var accountNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
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

    
    override func viewDidAppear(animated: Bool) {
        if let _ = KeychainWrapper.stringForKey(KEY_UID) {
            performSegueWithIdentifier("logIn", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func signInTapped(sender: FancyButton) {
        signIn()
    }
    
    func signIn() {
        if let account = accountNameField.text, let password = passwordField.text {
            FIRAuth.auth()?.signInWithEmail(account, password: password, completion: { (user, error) in
                if error == nil {
                    print("JAKE: Email user authenticated with Firebase")
                    if let user = user {
                        let storeData = ["provider" : user.providerID, "account" : account]
                        self.completeSignIn(user.uid, storeData: storeData)
                    }
                } else {
                    FIRAuth.auth()?.createUserWithEmail(account, password: password, completion: { (user, error) in
                        if error != nil {
                            print("JAKE: \(error)")
                            print("JAKE: Unable to authenticate with Firebase using email")
                        } else {
                            print("JAKE: Successfully authenticated with Firebase (email)")
                            if let user = user {
                                let storeData = ["provider" : user.providerID, "account" : account]
                                self.completeSignIn(user.uid, storeData: storeData)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIn(id: String, storeData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBStore(id, storeData: storeData)
        let keychainResult = KeychainWrapper.setString(id, forKey: KEY_UID)
        print("JAKE: Data saved to keychain \(keychainResult)")
        performSegueWithIdentifier("logIn", sender: nil)
    }

}
