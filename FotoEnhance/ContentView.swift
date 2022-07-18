//
//  ContentView.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 12/07/22.
//

import CoreML
import CoreGraphics
import Foundation
import Sliders
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
    @State private var isProcessing = false
    @State private var blendValue: Float = 50
    
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
                    ZStack {
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
                        if isProcessing {
                            EnhancementProgressView()
                        }
                    }
                }
                
                Spacer()
                
                VStack {
                    
                    // MARK: Blend Slider
                    
                    HStack {
                        Text("Enhancement")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .padding(.leading)
                            .padding(.bottom, 25)
                        VStack {
                            ValueSlider(value: $blendValue,
                                        in: 0...100,
                                        step: 1)
                            .valueSliderStyle(
                                HorizontalValueSliderStyle(track: Capsule()
                                    .frame(height: 5)
                                    .foregroundColor(imageEnhanced ? .mint : .gray),
                                                           thumb: Capsule()
                                    .frame(width: 16)
                                    .foregroundColor(.white)
                                    .shadow(radius: 6)
                                )
                            )
                            .padding(.leading, 10)
                            .padding(.trailing, 20)
                            .frame(height: 40)
                            .disabled(imageEnhanced ? false : true)
                            Text("\(Int(blendValue))")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .padding(.trailing, 10)
                        }
                    }
                    
                    // MARK: Enhancement Button
                    
                    Button(imageEnhanced ? EnhancementStatus.enhanced.rawValue : EnhancementStatus.notEnhanced.rawValue,
                           systemImage: SFSymbolName(rawValue: "wand.and.stars")!) {
                        
                        DispatchQueue.global(qos: .userInteractive).async {
                            
                            // Beginning enhancement process.
                            isProcessing = true
                            
                            // Safely unwrap the image.
                            guard let image = inputImage else {
                                print("Image not found.")
                                return
                            }
                            
                            // Enhance the image.
                            enhance(inputImage: image, outputImage: &processedImage)
                            
                            // Display the processed image.
                            DispatchQueue.main.async {
                                
                                // Enhancement is completed.
                                isProcessing = false
                                
                                // Image is now enhanced.
                                imageEnhanced = true
                                
                                // Set the processed image to image view.
                                imageView = Image(uiImage: processedImage!)
                            }
                        }
                    }
                           .applyModifiers(fontSize: 18,
                                           frameSize: (130, 40),
                                           foregroundColor: .adaptable(light: .black, dark: .white),
                                           backgroundColor: .adaptable(light: .white, dark: .black))
                           .padding(.vertical, 10)
                           .brightness(colorScheme == .light ? (imageEnhanced || inputImage == nil ? -0.3 : 0.0) : (imageEnhanced || inputImage == nil ? 0.3 : 0.0))
                           .disabled(imageEnhanced || inputImage == nil ? true : false)
                }
                
                Button("Send Feedback", systemImage: SFSymbolName(rawValue: "square.and.pencil")!) {
                    EmailHelper.shared.send(subject: "Feedback on FotoEnhance v0.3 (1)",
                                            body: """
                                                  🌱 Feature Request
                                                  What new feature you'd like us to add? 😊
                                                  
                                                  >>> Explain here
                                                  
                                                  🐞 Bug
                                                  What was the incorrect/unexpected behavior of the app?
                                                  
                                                  >>> Explain here
                                                  
                                                  💥 App Crash
                                                  What did you do that caused the app to crash?
                                                  
                                                  >>> Explain here
                                                  
                                                  ♥️ We highly appreciate that you're taking time to write to us.
                                                  """,
                                            to: ["rahulbhalley@icloud.com"])
                }
                .applyModifiers(fontSize: 18,
                                frameSize: (190, 40),
                                foregroundColor: .white,
                                backgroundColor: .mint)
                
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

func enhance(inputImage: UIImage, outputImage: inout UIImage?) {
    
    let inputImage512x512 = inputImage.resize(CGSize(width: 512, height: 512))
    //let originalImageSize = inputImage.size
    print("image size: \(inputImage512x512.size)")
    
    do {
        
        // Configuration for MLModel.
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all
        
        // Initialize the model.
        //let superResolutionModel = try AESRGAN_8Bit(configuration: configuration)
        //let vnCoremlModel = try VNCoreMLModel(for: AESRGAN_8Bit(configuration: configuration).model)
        let vnCoreMlRequest = VNCoreMLRequest(model: try VNCoreMLModel(for: RealESRGAN_8Bit(configuration: configuration).model))
        
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
        
        // Blend the input and enhanced images.
        blend(image1: inputImage.resize(CGSize(width: 2048, height: 2048)),
              image2: outputImage!,
              alpha: 0.8,
              outputImage: &outputImage)
        
        // Resize to original image aspect ratio.
        //outputImage = outputImage?.resizeLargerSideTo(length: 4096, aspectRatioOfImage: inputImage)
        let downScaledInputImage = inputImage.resizeLargerSideTo(length: 2048)
        let newWidth = downScaledInputImage.size.width// * 4
        let newHeight = downScaledInputImage.size.height// * 4
        print(inputImage512x512.size)
        print(downScaledInputImage.size)
        outputImage = outputImage?.resize(CGSize(width: newWidth, height: newHeight))
        
        // MARK: Add watermark to the processed image.
        
        // Remove the watermark if user have subscription.
        /*let backgroundImage = outputImage
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
        UIGraphicsEndImageContext()*/
    } catch {
        print(error)
    }
}

func blend(image1: UIImage,
           image2: UIImage,
           alpha: Float,
           outputImage: inout UIImage?) {
    let alpha = MLMultiArray(MLShapedArray<Float>(arrayLiteral: alpha))
    
    // MLModel configuration.
    let configuration = MLModelConfiguration()
    configuration.computeUnits = .all
    
    do {
        let blendModel = try Blend(configuration: configuration)
        let input = BlendInput(image1: image1.pixelBuffer!, image2: image2.pixelBuffer!, alpha: alpha)
        let blendedImage = try blendModel.prediction(input: input).blendedImage
        outputImage = imageFromPixelBuffer(pixelBuffer: blendedImage)
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
