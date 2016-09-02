//
//  RenderSettings.swift
//  FirebaseStarterPack
//
//  Created by Jake Jacobson on 9/2/16.
//  Copyright © 2016 JakeJacobson. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos

struct RenderSettings {
    
    var width: CGFloat = 1024
    var height: CGFloat = 1820
    var fps: Int32 = 5   // 2 frames per second
    var avCodecKey = AVVideoCodecH264
    var videoFilename = "fotomi "
    var videoFilenameExt = "mp4"
    
    var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    var outputURL: NSURL {
        // Use the CachesDirectory so the rendered video file sticks around as long as we need it to.
        // Using the CachesDirectory ensures the file won't be included in a backup of the app.
        let fileManager = NSFileManager.defaultManager()
        if let tmpDirURL = try? fileManager.URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true) {
            return tmpDirURL.URLByAppendingPathComponent(videoFilename).URLByAppendingPathExtension(videoFilenameExt)
        }
        fatalError("URLForDirectory() failed")
    }
    
    func randomAlphaNumericString(length: Int) -> String {
        
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in (0..<length) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
}