//
//  ImageSaver.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 12/07/22.
//

import UIKit

/// A class responsible for saving images to the device's photo album.
class ImageSaver: NSObject {
    
    /// A closure to be called upon successful image saving.
    var successHandler: (() -> Void)?
    
    /// A closure to be called if an error occurs during image saving.
    var errorHandler: ((Error) -> Void)?
    
    /// Saves the given image to the device's photo album.
    /// - Parameter image: The UIImage to be saved.
    func writeToPhotoAlbum(image: UIImage) {
        // Use UIKit's method to save the image to the photo album
        // This method will call the `saveCompleted` function when finished
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    /// Callback method invoked when the image saving process completes.
    /// - Parameters:
    ///   - image: The image that was saved (or attempted to be saved).
    ///   - error: An error object if the save operation failed, or nil if it succeeded.
    ///   - contextInfo: Additional context information (unused in this implementation).
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // If an error occurred, call the error handler
            errorHandler?(error)
        } else {
            // If successful, call the success handler
            successHandler?()
        }
    }
}

extension ImageSaver {
    /// A convenience method to save an image and handle the result using closures.
    /// - Parameters:
    ///   - image: The UIImage to be saved.
    ///   - completion: A closure to be called when the save operation completes.
    ///                 It provides a Bool indicating success and an optional Error.
    class func saveImage(_ image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        let saver = ImageSaver()
        
        saver.successHandler = {
            // Call the completion handler on the main queue
            DispatchQueue.main.async {
                completion(true, nil)
            }
        }
        
        saver.errorHandler = { error in
            // Call the completion handler on the main queue
            DispatchQueue.main.async {
                completion(false, error)
            }
        }
        
        saver.writeToPhotoAlbum(image: image)
    }
}
