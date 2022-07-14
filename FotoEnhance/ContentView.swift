//
//  ContentView.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 12/07/22.
//

import CoreML
import CoreGraphics
import Foundation
import SwiftUI
import SwiftUIX
import Vision

enum EnhancementStatus: String {
    case enhanced = "Enhanced"
    case notEnhanced = "Enhance"
}

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var imageView: Image?
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingAlert = false
    @State private var showingSubscription = false
    @State private var imageEnhanced = false
    
    var body: some View {
        ZStack {
            
            // MARK: Blurred Background Image
            
            Group {
                
                // Background image.
                if let inputImage = inputImage {
                    Image(uiImage: processedImage != nil ? processedImage! : inputImage)
                        .resizable()
                }
                
                // Blur the image.
                BlurEffectView(style: colorScheme == .light ? .light : .dark)
            }
            .ignoresSafeArea()
            
            // MARK: App Cnntent in Front of Blurred Background
            
            VStack {
                
                // MARK: Library and Save Buttons
                
                ZStack {
                    
                    if inputImage != nil {
                        Text("FotoEnhance")
                            .foregroundColor(.adaptable(light: .black, dark: .white))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .shadow(radius: 10)
                    }
                    
                    HStack {
                        Button("Library", systemImage: SFSymbolName(rawValue: "camera")!) {
                            showingImagePicker = true
                            imageEnhanced = false
                            processedImage = nil
                        }
                        .applyModifiers(fontSize: 16,
                                        frameSize: (100, 40),
                                        foregroundColor: .adaptable(light: .black, dark: .white),
                                        backgroundColor: .adaptable(light: .white, dark: .black))
                        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                            ImagePicker(image: $inputImage, sourceType: .photoLibrary)
                        }
                        
                        Spacer()
                        
                        Button("Save", systemImage: SFSymbolName(rawValue: "square.and.arrow.down")!) {
                            saveImage()
                        }
                        .applyModifiers(fontSize: 16,
                                        frameSize: (100, 40),
                                        foregroundColor: .adaptable(light: .black, dark: .white),
                                        backgroundColor: .adaptable(light: .white, dark: .black))
                        .brightness(colorScheme == .light ? (!imageEnhanced ? -0.3 : 0.0) : (!imageEnhanced ? 0.3 : 0.0))
                        .disabled(!imageEnhanced ? true : false)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // MARK: Image Display View
                
                if inputImage == nil {
                    VStack {
                        Text("FotoEnhance")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .shadow(radius: 10)
                        //Text("A Magical App to Enhance Photos")
                        Text("Magically Enhance Photos")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .shadow(radius: 10)
                    }
                }
                
                if inputImage != nil {
                    Spacer()
                }
                
                if inputImage != nil {
                    imageView?
                        .applyModifiers()
                        .onLongPressGesture(minimumDuration: 0.0001,
                                            perform: {
                            DispatchQueue.global(qos: .userInteractive).async {
                                imageView = Image(uiImage: processedImage!)
                                //print("long press.")
                            }
                        },
                                            onPressingChanged: { (isChanged: Bool) in
                            if isChanged {
                                imageView = Image(uiImage: inputImage!)
                                //print("Press changed.")
                            }
                        })
                }
                
                Spacer()
                
                if inputImage != nil {
                    Button(imageEnhanced ? EnhancementStatus.enhanced.rawValue : EnhancementStatus.notEnhanced.rawValue,
                           systemImage: SFSymbolName(rawValue: "wand.and.stars")!) {
                        
                        // Safely unwrap the image.
                        guard let image = inputImage else {
                            print("Image not found.")
                            return
                        }
                        
                        // Resize the input image.
                        /*if image.isAnySideGreaterThan(length: 512) {
                         image = image.resizeLargerSideTo(length: 512)
                         }*/
                        
                        // Make image super resolution.
                        process(inputImage: image, outputImage: &processedImage)
                        
                        // Display the user input image.
                        DispatchQueue.global(qos: .userInteractive).async {
                            imageView = Image(uiImage: processedImage!)
                        }
                        
                        // Image is now enhanced.
                        imageEnhanced = true
                    }
                           .applyModifiers(fontSize: 18,
                                           frameSize: (120, 40),
                                           foregroundColor: .adaptable(light: .black, dark: .white),
                                           backgroundColor: .adaptable(light: .white, dark: .black))
                           .padding(.vertical, 10)
                           .brightness(colorScheme == .light ? (imageEnhanced ? -0.3 : 0.0) : (imageEnhanced ? 0.3 : 0.0))
                           .disabled(imageEnhanced ? true : false)
                }
                
                // MARK: Enable the following code for first App Store release.
                
                /*Button("Unlock Pro", systemImage: SFSymbolName(rawValue: "lock.open.fill")!) {
                    // Code subscription here.
                    showingSubscription = true
                }
                .applyModifiers(fontSize: 16,
                                frameSize: (120, 40),
                                foregroundColor: .black,
                                backgroundColor: .yellow)
                .sheet(isPresented: $showingSubscription) {
                    SubscriptionView(showingSubscription: $showingSubscription)
                }
                Text("You can enhance 3 more photos today.")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .shadow(radius: 10)*/
            }
            .padding(.vertical)
        }
    }
}

// MARK: Functions

func process(inputImage: UIImage, outputImage: inout UIImage?) {
    
    let inputImage512x512 = inputImage.resize(CGSize(width: 512, height: 512))
    //    let originalImageSize = inputImage.size
    print("image size: \(inputImage512x512.size)")
    
    do {
        
        // Configuration for MLModel.
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all
        
        // Initialize the model.
        //let superResolutionModel = try AESRGAN_8Bit(configuration: configuration)
        //let vnCoremlModel = try VNCoreMLModel(for: AESRGAN_8Bit(configuration: configuration).model)
        let vnCoreMlRequest = VNCoreMLRequest(model: try VNCoreMLModel(for: AESRGAN_8Bit(configuration: configuration).model))
        
        let startTime = Date().timeIntervalSince1970
        /*let prediction = try superResolutionModel
         .prediction(lowResolutionImage: image.pixelBuffer!)
         ._4xHighResolutionImage
         processedImage = imageFromPixelBuffer(pixelBuffer: prediction)
         */
        guard let pixelBuffer = inputImage512x512.pixelBuffer else {
            print("Couldn't get the pixelbuffer.")
            return
        }
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try requestHandler.perform([vnCoreMlRequest])
        let endTime = Date().timeIntervalSince1970
        print("Inference took \(endTime - startTime) seconds.")
        
        /*if let observation = vnCoreMlRequest.results?.first as? VNPixelBufferObservation {
         print("The observation was found.")
         outputImage = imageFromPixelBuffer(pixelBuffer: observation.pixelBuffer)!
         }*/
        //print("outputImage size: \(outputImage!.size)")
        
        guard let observation = vnCoreMlRequest.results?.first as? VNPixelBufferObservation else {
            print("The observation was not found.")
            return
        }
        outputImage = imageFromPixelBuffer(pixelBuffer: observation.pixelBuffer)!
        
        // Resize to original image aspect ratio.
        //outputImage = outputImage?.resizeLargerSideTo(length: 4096, aspectRatioOfImage: inputImage)
        let downScaledInputImage = inputImage.resizeLargerSideTo(length: 2048)
        let newWidth = downScaledInputImage.size.width * 4
        let newHeight = downScaledInputImage.size.height * 4
        print(inputImage512x512.size)
        print(downScaledInputImage.size)
        outputImage = outputImage?.resize(CGSize(width: newWidth, height: newHeight))
        
        // MARK: Add watermark to the processed image.
        
        // Remove the watermark if user have subscription.
        let backgroundImage = outputImage
        let watermarkImage = UIImage(named: "Watermark")!
        
        let size = backgroundImage!.size
        let scale = backgroundImage!.scale
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        backgroundImage!.draw(in: CGRect(x: 0,
                                         y: 0,
                                         width: size.width,
                                         height: size.height))
        watermarkImage.draw(in: CGRect(x: 100,
                                       y: size.height - (100 + 200),
                                       width: 200,
                                       height: 200))
        
        outputImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    } catch {
        print(error)
    }
}

// MARK: Instance Methods

extension ContentView {
    
    /// Loads the image from either photo library or camera.
    func loadImage() {
        guard var inputImage = inputImage else {
            return
        }
        
        // Downscale the image.
        inputImage = inputImage.resizeLargerSideTo(length: 512)
        
        processedImage = inputImage
        imageView = Image(uiImage: inputImage)
    }
    
    /// Saves the processed image to photo library.
    func saveImage() {
        
        // Save the processed photo.
        guard let processedImage = self.processedImage else {
            return
        }
        
        // Initialize image saver instance.
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            // TODO: Show success alert using `VisualEffectBlurView`.
        }
        
        imageSaver.errorHandler = {
            
            // TODO: Show failure alert using `VisualEffectBlurView`.
            showingAlert = true
            print("Error: \($0.localizedDescription)")
        }
        
        // Write the processed image to photo library.
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
    }
}
