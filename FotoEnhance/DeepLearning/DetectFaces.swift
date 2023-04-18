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
    let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: inputImage.pixelBuffer!,
                                                    orientation: .up)
    
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
        print("face \(index).")
        print("normalizedCoordinates: \(face.boundingBox).")
        print("newCoordinates: \(transformNormalizedToImageCoordinates(from: face.boundingBox, to: inputImage.size)).")
    }
    guard let cgImage = inputImage.cgImage else { return (false, []) }
    if !results.isEmpty {
        // Get more area around detected face to cover hair as well.
        var faceCoordinates = transformNormalizedToImageCoordinates(from: results[0].boundingBox, to: inputImage.size)
        print("BEFORE")
        print("faceCoordinates.origin: \(faceCoordinates.origin)")
        print("faceCoordinates.size: \(faceCoordinates.size)")
        
        let moreAreaPercent = 0.4
        
        // Calculate new origin and size.
        let newX = faceCoordinates.minX - (faceCoordinates.width * moreAreaPercent)
        let newY = faceCoordinates.minY - (faceCoordinates.height * moreAreaPercent)
        let newWidth = faceCoordinates.width + 2 * (faceCoordinates.width * moreAreaPercent)
        let newHeight = faceCoordinates.height + 2 * (faceCoordinates.height * moreAreaPercent)
        
        // Set new origin nd size.
        faceCoordinates.origin = CGPoint(x: newX, y: newY)
        faceCoordinates.size = CGSize(width: newWidth, height: newHeight)
        print("AFTER")
        print("faceCoordinates.origin: \(faceCoordinates.origin)")
        print("faceCoordinates.size: \(faceCoordinates.size)")
        print("image.size: \(inputImage.size)")
        
        inputImage = UIImage(cgImage: cgImage.cropping(to: faceCoordinates)!)
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
    newCoordinates.origin.y = (imageCoordinates.height) - (imageCoordinates.height * normalizedCoordinates.origin.y)
    newCoordinates.origin.y = newCoordinates.origin.y - newCoordinates.size.height
    newCoordinates.origin.x = normalizedCoordinates.origin.x * imageCoordinates.size.width
    return newCoordinates
}
