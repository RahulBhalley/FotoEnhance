//
//  DetectFaces.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 02/12/22.
//

import UIKit
import Vision

@discardableResult
func faceDetectedAndBoundingBoxes(in inputImage: inout UIImage) -> (Bool, [CGRect]) {
    
    // Create a request handler.
    let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: inputImage.pixelBuffer!)
    
    // Create a face detection request.
    let request = VNDetectFaceRectanglesRequest()
    
    // Perform the request.
    do {
        try imageRequestHandler.perform([request])
    } catch {
        print(error)
    }
    
    // Return the result.
    guard let results = request.results else {
        NSLog("In `\(#function)`, request.results is nil.")
        return (false, [])
    }
    
    for (index, face) in results.enumerated() {
        print("face \(index):")
        print("normalizedCoordinates: \(face.boundingBox):")
        print("newCoordinates: \(transformNormalizedToImageCoordinates(from: face.boundingBox, to: inputImage.size))")
    }
    guard let cgImage = inputImage.cgImage else { return (false, []) }
    if !results.isEmpty {
        inputImage = UIImage(cgImage: cgImage.cropping(to: transformNormalizedToImageCoordinates(from: results[0].boundingBox, to: inputImage.size))!)
        print(inputImage.size)
    }
    
    let boundingBoxes = results.map { $0.boundingBox }
    return (results.isEmpty ? false : true, boundingBoxes)
}

/// Transform the normalized Vision coordinates to image coordinates.
/// - Parameters:
///   - normalizedCoordinates: The normalized coordinates.
///   - imageCoordinates: The image coordinates.
/// - Returns: The normalized coordinates transformed to image coordinates.
func transformNormalizedToImageCoordinates(from normalizedCoordinates: CGRect, to imageSize: CGSize) -> CGRect {
    let imageCoordinates = CGRect(origin: CGPoint(x: 0, y: 0), size: imageSize)
    var newCoordinates = CGRect()
    newCoordinates.size.width = normalizedCoordinates.size.width * imageCoordinates.size.width
    newCoordinates.size.height = normalizedCoordinates.size.height * imageCoordinates.size.height
    newCoordinates.origin.y = (imageCoordinates.height) - (imageCoordinates.height * normalizedCoordinates.origin.y )
    newCoordinates.origin.y = newCoordinates.origin.y - newCoordinates.size.height
    newCoordinates.origin.x = normalizedCoordinates.origin.x * imageCoordinates.size.width
    return newCoordinates
}
