//
//  EnhanceImage.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 02/12/22.
//

import UIKit
import Vision

func enhanceImage(inputImage: UIImage, outputImage: inout UIImage?) {
    do {
        // Configuration for MLModel.
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all
        
        // Initialize the model.
        let vnCoreMlRequest = VNCoreMLRequest(model: try VNCoreMLModel(for: RealESRGAN_8Bit(configuration: configuration).model))
        
        let startTime = Date().timeIntervalSince1970
        guard let pixelBuffer = inputImage.resize(CGSize(width: 512, height: 512)).pixelBuffer else {
            print("\(#function) Couldn't get the pixelbuffer.")
            return
        }
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try requestHandler.perform([vnCoreMlRequest])
        let endTime = Date().timeIntervalSince1970
        print("[Image Enhancement] Inference took \(endTime - startTime) seconds.")
        
        guard let observation = vnCoreMlRequest.results?.first as? VNPixelBufferObservation else {
            print("The observation was not found.")
            return
        }
        outputImage = imageFromPixelBuffer(pixelBuffer: observation.pixelBuffer)!
    } catch {
        print(error)
    }
}
