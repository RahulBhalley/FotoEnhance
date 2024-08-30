//
//  Extensions.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 12/07/22.
//

import SwiftUI

// MARK: - SwiftUI Extensions

extension Image {
    /// Applies common modifiers to create a consistent image style.
    /// - Returns: A modified view with standard styling applied.
    func applyStandardStyle() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(10)
            .shadow(radius: 6)
            .padding(.horizontal, 20)
    }
}

extension Button {
    /// Applies common modifiers to create a consistent button style.
    /// - Parameters:
    ///   - fontSize: The size of the button's text.
    ///   - frameSize: A tuple containing the width and height of the button.
    ///   - foregroundColor: The color of the button's text (default is white).
    ///   - backgroundColor: The background color of the button (default is black).
    /// - Returns: A modified view with standard button styling applied.
    func applyStandardStyle(fontSize: CGFloat,
                            frameSize: (width: CGFloat, height: CGFloat),
                            foregroundColor: Color = .white,
                            backgroundColor: Color = .black) -> some View {
        self
            .font(.system(size: fontSize, weight: .bold, design: .rounded))
            .frame(width: frameSize.width, height: frameSize.height)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .cornerRadius(8)
            .shadow(radius: 6)
    }
}

// MARK: - UIKit Extensions

extension UIImage {
    /// Converts the UIImage to a CVPixelBuffer.
    /// - Returns: A CVPixelBuffer representation of the image, or nil if conversion fails.
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let frameSize = CGSize(width: size.width, height: size.height)
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(frameSize.width),
                                         Int(frameSize.height),
                                         kCVPixelFormatType_32BGRA,
                                         nil,
                                         &pixelBuffer)
        
        guard status == kCVReturnSuccess, let unwrappedPixelBuffer = pixelBuffer else {
            print("Failed to create CVPixelBuffer")
            return nil
        }
        
        CVPixelBufferLockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(unwrappedPixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        guard let context = CGContext(data: data,
                                      width: Int(frameSize.width),
                                      height: Int(frameSize.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(unwrappedPixelBuffer),
                                      space: rgbColorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else {
            print("Failed to create CGContext")
            return nil
        }
        
        context.draw(cgImage!, in: CGRect(origin: .zero, size: frameSize))
        CVPixelBufferUnlockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return unwrappedPixelBuffer
    }
    
    /// Calculates the aspect ratio of the image.
    /// - Returns: The aspect ratio as a CGFloat (width / height).
    private func aspectRatio() -> CGFloat {
        return size.width / size.height
    }

    /// Resizes the image while maintaining its aspect ratio.
    /// - Parameter length: The desired length of the longer side of the image.
    /// - Returns: A resized UIImage.
    func resizeMaintainingAspectRatio(to length: CGFloat) -> UIImage {
        let ratio = self.aspectRatio()
        
        let newSize: CGSize
        if ratio > 1 {
            // Width is longer
            newSize = CGSize(width: length, height: length / ratio)
        } else {
            // Height is longer or square
            newSize = CGSize(width: length * ratio, height: length)
        }
        
        return resize(to: newSize)
    }

    /// Resizes the image to the specified size.
    /// - Parameter size: The desired size for the image.
    /// - Returns: A resized UIImage.
    func resize(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    /// Resizes the image to match the aspect ratio of another image.
    /// - Parameter otherImage: The image whose aspect ratio should be matched.
    /// - Returns: A resized UIImage with the same aspect ratio as the other image.
    func resizeToMatchAspectRatio(of otherImage: UIImage) -> UIImage {
        let targetRatio = otherImage.aspectRatio()
        let currentRatio = self.aspectRatio()
        
        let newSize: CGSize
        if currentRatio > targetRatio {
            // Current image is wider, adjust width
            newSize = CGSize(width: size.height * targetRatio, height: size.height)
        } else {
            // Current image is taller, adjust height
            newSize = CGSize(width: size.width, height: size.width / targetRatio)
        }
        
        return resize(to: newSize)
    }

    /// Checks if either side of the image is greater than the specified length.
    /// - Parameter length: The length to compare against.
    /// - Returns: True if either side is greater than the specified length, false otherwise.
    func isAnySideGreaterThan(_ length: CGFloat) -> Bool {
        return self.size.height > length || self.size.width > length
    }
}
