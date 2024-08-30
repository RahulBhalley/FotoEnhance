//
//  AddWatermark.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 01/12/22.
//

import UIKit

/// Adds a watermark to an image.
struct WatermarkAdder {
    
    /// The image to which the watermark will be added.
    private let backgroundImage: UIImage
    
    /// The watermark image to be added.
    private let watermarkImage: UIImage
    
    /// Initializes a new WatermarkAdder instance.
    /// - Parameters:
    ///   - backgroundImage: The image to which the watermark will be added.
    ///   - watermarkImage: The watermark image to be added.
    init(backgroundImage: UIImage, watermarkImage: UIImage) {
        self.backgroundImage = backgroundImage
        self.watermarkImage = watermarkImage
    }
    
    /// Adds the watermark to the background image.
    /// - Returns: A new UIImage with the watermark added.
    func addWatermark() -> UIImage {
        let size = backgroundImage.size
        let scale = backgroundImage.scale
        
        // Begin a new image context
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        // Draw the background image
        backgroundImage.draw(in: CGRect(origin: .zero, size: size))
        
        // Calculate watermark position (bottom right corner)
        let watermarkSize = CGSize(width: 200, height: 200)
        let watermarkOrigin = CGPoint(x: size.width - watermarkSize.width - 100,
                                      y: size.height - watermarkSize.height - 100)
        
        // Draw the watermark
        watermarkImage.draw(in: CGRect(origin: watermarkOrigin, size: watermarkSize))
        
        // Get the new image with watermark
        let watermarkedImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // End the image context
        UIGraphicsEndImageContext()
        
        return watermarkedImage
    }
}

extension UIImage {
    /// Adds a watermark to the image.
    /// - Parameter watermarkName: The name of the watermark image in the asset catalog.
    /// - Returns: A new UIImage with the watermark added, or the original image if the watermark couldn't be found.
    func addingWatermark(named watermarkName: String) -> UIImage {
        guard let watermarkImage = UIImage(named: watermarkName) else {
            print("Watermark image not found: \(watermarkName)")
            return self
        }
        
        let adder = WatermarkAdder(backgroundImage: self, watermarkImage: watermarkImage)
        return adder.addWatermark()
    }
}
