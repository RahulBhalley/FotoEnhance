//
//  EnhanceImage.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 02/12/22.
//

import UIKit
import Vision

/// Enhances the quality of an input image using the RealESRGAN model.
/// - Parameter inputImage: The original image to be enhanced.
/// - Returns: An optional `UIImage` containing the enhanced image, or `nil` if enhancement fails.
func enhanceImage(_ inputImage: UIImage) -> UIImage? {
    do {
        // Configure MLModel to use all available compute units
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all
        
        // Initialize the RealESRGAN model
        let realESRGANModel = try VNCoreMLModel(for: RealESRGAN_8Bit(configuration: configuration).model)
        let request = VNCoreMLRequest(model: realESRGANModel)
        
        // Measure inference time
        let startTime = Date()
        
        // Resize input image to 512x512 and convert to pixel buffer
        guard let pixelBuffer = inputImage.resize(to: CGSize(width: 512, height: 512)).pixelBuffer else {
            print("Failed to create pixel buffer from resized input image.")
            return nil
        }
        
        // Perform image enhancement
        try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up).perform([request])
        
        let inferenceTime = Date().timeInterval(since: startTime)
        print("[Image Enhancement] Inference took \(inferenceTime) seconds.")
        
        // Extract the enhanced image from the observation
        guard let enhancedPixelBuffer = (request.results?.first as? VNPixelBufferObservation)?.pixelBuffer else {
            print("Failed to get enhanced pixel buffer from observation.")
            return nil
        }
        
        return UIImage(pixelBuffer: enhancedPixelBuffer)
    } catch {
        print("Image enhancement failed: \(error)")
        return nil
    }
}

extension UIImage {
    /// Resizes the image to the specified size.
    /// - Parameter size: The target size for the resized image.
    /// - Returns: A new `UIImage` instance with the specified size.
    func resize(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? self
    }
    
    /// Converts the image to a CVPixelBuffer.
    var pixelBuffer: CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(self.size.width),
                                         Int(self.size.height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)
        
        guard status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: Int(self.size.width),
                                      height: Int(self.size.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                      space: rgbColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            return nil
        }
        
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}

extension UIImage {
    /// Initializes a UIImage from a CVPixelBuffer.
    /// - Parameter pixelBuffer: The CVPixelBuffer to convert to a UIImage.
    convenience init?(pixelBuffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}
