//
//  EnhanceFace.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 02/12/22.
//

import UIKit
import Vision

/// Enhances faces in an image using the GFPGAN model.
/// - Parameter inputImage: The input image containing faces to be enhanced.
/// - Returns: An optional `UIImage` with enhanced faces, or `nil` if the process fails.
func enhanceFaces(in inputImage: UIImage) -> UIImage? {
    do {
        // Configure MLModel to use CPU only
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .cpuOnly
        
        // Initialize the GFPGAN model
        let gfpganModel = try VNCoreMLModel(for: GFPGAN_8Bit(configuration: configuration).model)
        let request = VNCoreMLRequest(model: gfpganModel)
        
        // Measure inference time
        let startTime = Date()
        
        guard let pixelBuffer = inputImage.pixelBuffer else {
            print("Failed to create pixel buffer from input image.")
            return nil
        }
        
        // Perform face enhancement
        try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up).perform([request])
        
        let inferenceTime = Date().timeInterval(since: startTime)
        print("[Face Enhancement] Inference took \(inferenceTime) seconds.")
        
        // Extract the enhanced image from the observation
        guard let enhancedPixelBuffer = (request.results?.first as? VNPixelBufferObservation)?.pixelBuffer else {
            print("Failed to get enhanced pixel buffer from observation.")
            return nil
        }
        
        return UIImage(pixelBuffer: enhancedPixelBuffer)
    } catch {
        print("Face enhancement failed: \(error)")
        return nil
    }
}
