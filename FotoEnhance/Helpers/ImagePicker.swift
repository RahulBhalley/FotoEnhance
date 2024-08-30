//
//  ImagePicker.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 12/07/22.
//

import SwiftUI

/// A SwiftUI wrapper for UIImagePickerController to select images from the device.
struct ImagePicker: UIViewControllerRepresentable {
    
    /// The presentation mode of the current view.
    @Environment(\.presentationMode) private var presentationMode
    
    /// Binding to the selected image.
    @Binding var image: UIImage?
    
    /// The source type for the image picker (e.g., camera or photo library).
    let sourceType: UIImagePickerController.SourceType
    
    /// Creates and returns a UIImagePickerController configured with the specified options.
    /// - Parameter context: The context in which the picker is created.
    /// - Returns: A configured UIImagePickerController instance.
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        
        // Restrict media types to images only
        picker.mediaTypes = ["public.image"]
        
        return picker
    }
    
    /// Updates the UIImagePickerController (not used in this implementation).
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        // No update needed
    }
    
    /// Creates and returns a coordinator to manage the UIImagePickerController.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// Coordinator class to handle the UIImagePickerControllerDelegate methods.
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        /// The parent ImagePicker instance.
        let parent: ImagePicker
        
        /// Initializes the Coordinator with a reference to the parent ImagePicker.
        /// - Parameter parent: The ImagePicker instance this coordinator is associated with.
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        /// Called when the user finishes picking a media item.
        /// - Parameters:
        ///   - picker: The image picker instance.
        ///   - info: A dictionary containing the picked image and associated metadata.
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            
            // Dismiss the image picker
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
