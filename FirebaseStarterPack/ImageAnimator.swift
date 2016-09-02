//
//  ImageAnimator.swift
//  FirebaseStarterPack
//
//  Created by Jake Jacobson on 9/2/16.
//  Copyright © 2016 JakeJacobson. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos

class ImageAnimator {
    
    // Apple suggests a timescale of 600 because it's a multiple of standard video rates 24, 25, 30, 60 fps etc.
    static let kTimescale: Int32 = 600
    
    let settings: RenderSettings
    let videoWriter: VideoWriter
    var images2 = [UIImage]()
    
    var frameNum = 0
    
    class func saveToLibrary(videoURL: NSURL) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .Authorized else { return }
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(videoURL)
            }) { success, error in
                if !success {
                    print("Could not save video to photo library:", error)
                }
            }
        }
    }
    
    class func removeFileAtURL(fileURL: NSURL) {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(fileURL.path!)
        }
        catch _ as NSError {
            // Assume file doesn't exist.
        }
    }
    
    init(renderSettings: RenderSettings, images: [UIImage]) {
        settings = renderSettings
        videoWriter = VideoWriter(renderSettings: settings)
        for image in images {
            images2.append(image)
        }
    }
    
    func render(completion: ()->Void) {
        
        // The VideoWriter will fail if a file exists at the URL, so clear it out first.
        ImageAnimator.removeFileAtURL(settings.outputURL)
        
        videoWriter.start()
        videoWriter.render(appendPixelBuffers) {
            ImageAnimator.saveToLibrary(self.settings.outputURL)
            completion()
        }
        
    }
    
    // This is the callback function for VideoWriter.render()
    func appendPixelBuffers(writer: VideoWriter) -> Bool {
        
        let frameDuration = CMTimeMake(Int64(ImageAnimator.kTimescale / settings.fps), ImageAnimator.kTimescale)
        
        while !images2.isEmpty {
            
            if writer.isReadyForData == false {
                // Inform writer we have more buffers to write.
                return false
            }
            
            let image = images2.removeFirst()
            let presentationTime = CMTimeMultiply(frameDuration, Int32(frameNum))
            let success = videoWriter.addImage(image, withPresentationTime: presentationTime)
            if success == false {
                fatalError("addImage() failed")
            }
            
            frameNum += 1
        }
        
        // Inform writer all buffers have been written.
        return true
    }
}