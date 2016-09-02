//
//  DataService.swift
//  FirebaseStarterPack
//
//  Created by Jake Jacobson on 8/25/16.
//  Copyright © 2016 JakeJacobson. All rights reserved.
//

import Foundation

import Firebase

let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    //Storage references
    private var _REF_POST_IMAGES = STORAGE_BASE.child("post-pics")
    
    var REF_POST_IMAGES: FIRStorageReference {
        return _REF_POST_IMAGES
    }
    
    //DB references
    private var _REF_BASE = DB_BASE
    private var _REF_CUSTOMERS = DB_BASE.child("customers")
    private var _REF_STORES = DB_BASE.child("stores")
    private var _REF_VIDEOS = DB_BASE.child("videos")
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_CUSTOMERS: FIRDatabaseReference {
        return _REF_CUSTOMERS
    }
    
    var REF_STORES: FIRDatabaseReference {
        return _REF_STORES
    }
    
    var REF_VIDEOS: FIRDatabaseReference {
        return _REF_VIDEOS
    }
    
    func createFirebaseDBStore(uid: String, storeData: Dictionary<String, String>) {
        REF_STORES.child(uid).updateChildValues(storeData)
    }
    
    func createFirebaseDBCustomer(email: String, customerData: Dictionary<String, String>) {
        REF_CUSTOMERS.child(email).updateChildValues(customerData)
    }
    
    //this function handles the logic of linking/creating customers and videos to stores
    func linkEmUp(cid: String, sid: String, cidTrue: Dictionary<String, String> ,sidTrue: Dictionary<String, String>, cData: Dictionary<String, String>) {
        REF_CUSTOMERS.child(cid).observeEventType(.Value, withBlock: { (snapshot) in
            if snapshot.exists() {
                //customer exists
                self.REF_STORES.child(sid).child("customer").child(cid).observeEventType(.Value, withBlock: { (snapshot) in
                    if snapshot.exists() {
                        //customer exists in customers and in current store
                        
                        //create new video
                        //goes here
                        
                        //link customer to video
                        //goes here
                        
                        //link store to video
                        //goes here
                        
                    } else {
                        //customer exists in customers but not in current store
                        
                        //create new video
                        //goes here
                        
                        //link customer to store
                        self.REF_CUSTOMERS.child(cid).child("stores").updateChildValues(sidTrue)
                        
                        //link store to customer
                        self.REF_STORES.child(sid).child("customers").updateChildValues(cidTrue)
                        
                        //link customer to video
                        //goes here
                        
                        //link store to video
                        //goes here
                    }
                })
            } else {
                //customer does not exist in customers
                
                //create new customer in customers
                self.createFirebaseDBCustomer(cid, customerData: cData)
                
                //create new video
                //goes here
                
                //link customer to store
                self.REF_CUSTOMERS.child(cid).child("stores").updateChildValues(sidTrue)
                
                //link store to customer
                self.REF_STORES.child(sid).child("customers").updateChildValues(cidTrue)
                
                //link customer to video
                //goes here
                
                //link store to video
                //goes here
            }
        })
    }
    
}