//
//  EnhanceFace.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 02/12/22.
//

import UIKit
import Vision

/// Enhances the faces and pastes them back in their original location.
/// - Parameters:
///   - inputImage: The input image in which faces are the be enhanced.
///   - outputImage: The output image in which faces are enhanced.
func enhanceFace(inputImage: UIImage, outputImage: inout UIImage?) {
    do {
        // Configuration for MLModel.
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .cpuOnly
        
        // Initialize the model.
        let vnCoreMlRequest = VNCoreMLRequest(model: try VNCoreMLModel(for: GFPGAN_8Bit(configuration: configuration).model))
        
        let startTime = Date().timeIntervalSince1970
        guard let pixelBuffer = inputImage.pixelBuffer else {
            print("\(#function) Couldn't get the pixelbuffer.")
            return
        }
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try requestHandler.perform([vnCoreMlRequest])
        let endTime = Date().timeIntervalSince1970
        print("[Face Enhancement] Inference took \(endTime - startTime) seconds.")
        
        guard let observation = vnCoreMlRequest.results?.first as? VNPixelBufferObservation else {
            print("The observation was not found.")
            return
        }
        outputImage = imageFromPixelBuffer(pixelBuffer: observation.pixelBuffer)!
    } catch {
        print(error)
    }
}
