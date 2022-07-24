//
//  Extensions.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 12/07/22.
//

import SwiftUI

// MARK: SwiftUI

extension Image {
    func applyModifiers() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(10)
            .shadow(radius: 6)
            .padding(.horizontal, 20)
    }
}

extension Button {
    func applyModifiers(fontSize: CGFloat,
                        frameSize: (CGFloat, CGFloat),
                        foregroundColor: Color = .white,
                        backgroundColor: Color = .black) -> some View {
        self
            .font(.system(size: fontSize, weight: .bold, design: .rounded))
            .frame(width: frameSize.0, height: frameSize.1)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .cornerRadius(8)
            .shadow(radius: 6)
    }
}

// MARK: UIKit

public func imageFromPixelBuffer(pixelBuffer: CVPixelBuffer) -> UIImage? {
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    guard let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else { return nil }
    let image = UIImage(cgImage: cgImage)
    return image
}

extension UIImage {
    
    public var pixelBuffer: CVPixelBuffer? {
        guard let cgImage = cgImage else { return nil }
        let frameSize = CGSize(width: cgImage.width, height: cgImage.height)
        var pixelBuffer:CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(frameSize.width),
                                         Int(frameSize.height),
                                         kCVPixelFormatType_32BGRA,
                                         nil,
                                         &pixelBuffer)
        if status != kCVReturnSuccess { return nil }
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let context = CGContext(data: data,
                                width: Int(frameSize.width),
                                height: Int(frameSize.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                space: rgbColorSpace,
                                bitmapInfo: bitmapInfo.rawValue)
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
    
    /// Resizes the image with the given larger side, maintaining the aspect ratio.
    /// - Parameter length: The length of larger size.
    /// - Returns: Resized image.
    func resizeLargerSideTo(length: CGFloat) -> UIImage {
        var resultImage = UIImage()
        if self.size.width == self.size.height {
            resultImage = Toucan(image: self).resize(CGSize(width: length, height: length)).uiImage!
        } else if self.size.height > self.size.width {
            //let pixelsCondition = (self.size.height / (self.size.height / length)) * (self.size.width / (self.size.height / length)) >= (700 * 1_000)
            //let length: CGFloat = pixelsCondition ? 900 : 1_000
            let ratio = self.size.height / length
            let newWidth = self.size.width / ratio
            let newHeight = self.size.height / ratio
            resultImage = Toucan(image: self).resizeByScaling(CGSize(width: newWidth, height: newHeight)).uiImage!
        } else if self.size.width > self.size.height {
            let ratio = self.size.width / length
            let newWidth = self.size.width / ratio
            let newHeight = self.size.height / ratio
            resultImage = Toucan(image: self).resizeByScaling(CGSize(width: newWidth, height: newHeight)).uiImage!
        }
        return resultImage
    }
    
    func resize(_ size: CGSize) -> UIImage {
        Toucan(image: self).resizeByScaling(size).uiImage!
    }
    
    func resizeLargerSideTo(length: CGFloat = 2048, aspectRatioOfImage originalImage: UIImage) -> UIImage {
        //var resultImage = UIImage()
        var ratio: CGFloat = 1.0
        if originalImage.size.height > originalImage.size.width {
            ratio = length / originalImage.size.height
        } else if originalImage.size.width > originalImage.size.height {
            ratio = originalImage.size.width / length
        } else if originalImage.size.width == originalImage.size.height {
            ratio = 1.0
        }
        
        // Resize while maintaining the aspect ratio of original image.
        let newWidth = originalImage.size.width / ratio
        let newHeight = originalImage.size.height / ratio
        
        print("newWidth: \(newWidth)")
        print("newHeight: \(newHeight)")
        
        //resultImage = Toucan(image: self).resizeByScaling(CGSize(width: newWidth, height: newHeight)).uiImage!
        return Toucan(image: self).resizeByScaling(CGSize(width: newWidth, height: newHeight)).uiImage!
        
        //return resultImage
    }
}

extension UIImage {
    
    public func isAnySideGrefaterThan(length: CGFloat) -> Bool {
        self.size.height > length || self.size.width > length
    }
}
