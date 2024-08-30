//
//  DetectFaces.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 02/12/22.
//

import UIKit
import Vision

/// Detects faces in the given image and returns their bounding boxes.
/// - Parameter image: The input image to process.
/// - Returns: A tuple containing a boolean indicating if faces were detected and an array of face bounding boxes.
@discardableResult
func detectFacesAndBoundingBoxes(in image: inout UIImage) -> (faceDetected: Bool, boundingBoxes: [CGRect]) {
    // Create a request handler
    guard let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image.pixelBuffer!, orientation: .up) else {
        NSLog("Failed to create VNImageRequestHandler in \(#function)")
        return (false, [])
    }
    
    // Create a face detection request
    let request = VNDetectFaceRectanglesRequest()
    
    // Perform the request
    do {
        try imageRequestHandler.perform([request])
    } catch {
        NSLog("Face detection failed in \(#function): \(error)")
        return (false, [])
    }
    
    // Process the results
    guard let results = request.results else {
        NSLog("No results from face detection in \(#function)")
        return (false, [])
    }
    
    for (index, face) in results.enumerated() {
        NSLog("Face \(index) detected at normalized coordinates: \(face.boundingBox)")
        NSLog("Face \(index) detected at image coordinates: \(transformNormalizedToImageCoordinates(from: face.boundingBox, to: image.size))")
    }
    
    guard let cgImage = image.cgImage, !results.isEmpty else { return (false, []) }
    
    // Expand the detected face area
    let faceCoordinates = expandFaceArea(for: results[0].boundingBox, in: image.size)
    
    NSLog("Expanded face coordinates: origin = \(faceCoordinates.origin), size = \(faceCoordinates.size)")
    NSLog("Image size: \(image.size)")
    
    if let croppedImage = cgImage.cropping(to: faceCoordinates) {
        image = UIImage(cgImage: croppedImage)
        NSLog("Cropped image size: \(image.size)")
    }
    
    let boundingBoxes = results.map { $0.boundingBox }
    return (!results.isEmpty, boundingBoxes)
}

/// Expands the given face area by a certain percentage.
/// - Parameters:
///   - boundingBox: The normalized coordinates of the face.
///   - imageSize: The size of the original image.
/// - Returns: The expanded face coordinates in image space.
private func expandFaceArea(for boundingBox: CGRect, in imageSize: CGSize) -> CGRect {
    let expandFactor = 0.4
    let imageCoordinates = transformNormalizedToImageCoordinates(from: boundingBox, to: imageSize)
    
    let newX = imageCoordinates.minX - (imageCoordinates.width * expandFactor)
    let newY = imageCoordinates.minY - (imageCoordinates.height * expandFactor)
    let newWidth = imageCoordinates.width * (1 + 2 * expandFactor)
    let newHeight = imageCoordinates.height * (1 + 2 * expandFactor)
    
    return CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
}

/// Transforms normalized Vision coordinates to image coordinates.
/// - Parameters:
///   - normalizedCoordinates: The normalized coordinates from Vision.
///   - imageSize: The size of the image.
/// - Returns: The coordinates transformed to image space.
func transformNormalizedToImageCoordinates(from normalizedCoordinates: CGRect, to imageSize: CGSize) -> CGRect {
    var imageCoordinates = CGRect()
    imageCoordinates.size.width = normalizedCoordinates.width * imageSize.width
    imageCoordinates.size.height = normalizedCoordinates.height * imageSize.height
    imageCoordinates.origin.y = (imageSize.height) - (imageSize.height * normalizedCoordinates.origin.y) - imageCoordinates.height
    imageCoordinates.origin.x = normalizedCoordinates.origin.x * imageSize.width
    return imageCoordinates
}
