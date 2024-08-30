import SwiftUI

/// A struct containing helper methods for image processing and manipulation
struct ImageViewHelpers {
    /// Handles zoom gestures on the image view
    /// - Parameters:
    ///   - value: The current value of the magnification gesture
    ///   - lastScale: The previous scale value, updated after handling the zoom
    ///   - scale: The current scale value, updated based on the zoom gesture
    static func handleZoom(value: MagnificationGesture.Value, lastScale: inout CGFloat, scale: inout CGFloat) {
        let delta = value / lastScale
        lastScale = value
        let newScale = scale * delta
        scale = newScale
    }
    
    /// Blends the original and enhanced images based on the blend value
    /// - Parameters:
    ///   - inputImage: The original input image
    ///   - enhancedImage1024: The 1024x1024 enhanced image
    ///   - enhancedImage2048: The 2048x2048 enhanced image
    ///   - blendValue: The blend value between 0 and 100
    ///   - resolution: The target resolution for blending (1024 or 2048)
    ///   - completion: A closure called with the resulting blended image
    static func blendImages(inputImage: UIImage?, enhancedImage1024: UIImage?, enhancedImage2048: UIImage?, blendValue: Float, resolution: Int, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            guard let image = inputImage else { return }
            
            // Choose the appropriate enhanced image based on the resolution
            let enhancedImageToUse = resolution == 1024 ? enhancedImage1024 : enhancedImage2048
            
            // Blend the images
            let blendedImage = blend(image1: image.resize(CGSize(width: resolution, height: resolution)),
                                     image2: enhancedImageToUse!,
                                     alpha: blendValue,
                                     resolution: resolution)
            
            // Resize the blended image to match the original image size
            let resizedBlendedImage = blendedImage?.resize(image.resizeLargerSideTo(length: 2048).size)
            
            DispatchQueue.main.async {
                completion(resizedBlendedImage)
            }
        }
    }
    
    /// Enhances the input image using the ML model
    /// - Parameters:
    ///   - inputImage: The original input image to be enhanced
    ///   - completion: A closure called with the enhanced images (original size, 1024x1024, and 2048x2048)
    static func enhanceImage(inputImage: UIImage, completion: @escaping (UIImage?, UIImage?, UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            var enhancedImage: UIImage?
            
            // Perform the image enhancement
            enhanceImage(inputImage: inputImage, outputImage: &enhancedImage)
            
            // Create resized versions of the enhanced image
            let enhancedImage1024 = enhancedImage?.resize(CGSize(width: 1024, height: 1024))
            let enhancedImage2048 = enhancedImage?.resize(CGSize(width: 2048, height: 2048))
            
            DispatchQueue.main.async {
                completion(enhancedImage, enhancedImage1024, enhancedImage2048)
            }
        }
    }
}