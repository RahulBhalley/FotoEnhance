//
//  ContentView.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 12/07/22.
//

import CoreML
import CoreGraphics
import DeviceKit
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
    
    // MARK: Image Properties
    
    @State private var imageView: Image?
    @State private var inputImage: UIImage?
    @State private var enhancedImage: UIImage?
    @State private var enhancedImage1024: UIImage?
    @State private var enhancedImage2048: UIImage?
    @State private var blendedImage: UIImage?
    
    // MARK: Boolean Properties
    
    @State private var showingImagePicker = false
    @State private var showingAlert = false
    @State private var showingSubscription = false
    //@State private var showingFeedbackRequest = false
    @State private var imageEnhanced = false
    @State private var imageSaved = false
    @State private var isProcessing = false
    @State private var justLaunched = true
    
    // MARK: Number Properties
    
    @State private var blendValue: Float = 50
    @State private var oldBlendValue: Float = 50
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    // MARK: Others
    private let device = Device.current
    var resolution: Int {
        if Device.current == .iPhone13 {
            return 2048
        } else {
            return 1024
        }
    }
    
    var body: some View {
        ZStack {
            
            // MARK: Blurred Background Image
            
            Group {
                
                // Background image.
                if let inputImage = inputImage {
                    Image(uiImage: enhancedImage != nil ? enhancedImage! : inputImage)
                        .resizable()
                }
                
                // Blur the image.
                BlurEffectView(style: colorScheme == .light ? .light : .dark)
            }
            .ignoresSafeArea()
            
            // MARK: App Cnntent in Front of Blurred Background
            
            VStack {
                
                ZStack {
                    
                    // MARK: Middle FotoEnhance Text
                    
                    if inputImage != nil {
                        Text("FotoEnhance")
                            .foregroundColor(.adaptable(light: .black, dark: .white))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .shadow(radius: 10)
                    }
                                        
                    HStack {

                        // MARK: Library Button

                        Button("Library", systemImage: SFSymbolName(rawValue: "camera")!) {
                            showingImagePicker = true
                            imageEnhanced = false
                            enhancedImage = nil
                        }
                        .applyModifiers(fontSize: 16,
                                        frameSize: (100, 40),
                                        foregroundColor: .adaptable(light: .black, dark: .white),
                                        backgroundColor: .adaptable(light: .white, dark: .black))
                        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                            ImagePicker(image: $inputImage, sourceType: .photoLibrary)
                        }
                        .brightness(colorScheme == .light ? (isProcessing ? -0.3 : 0.0) : (isProcessing ? 0.3 : 0.0))
                        .disabled(isProcessing ? true : false)
                        
                        Spacer()
                        
                        // MARK: Save Button
                        
                        Button("Save", systemImage: SFSymbolName(rawValue: "square.and.arrow.down")!) {
                            
                            // Save the image.
                            saveImage()
                            
                            // Present save image view.
                            imageSaved = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                imageSaved = false
                            }
                            
                            // Run haptic feedback.
                            Haptics.shared.run(.heavy)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.125) {
                                Haptics.shared.run(.heavy)
                            }
                            
                            // Now present a feedback request popover.
                            //showingFeedbackRequest = true
                        }
                        .applyModifiers(fontSize: 16,
                                        frameSize: (100, 40),
                                        foregroundColor: .adaptable(light: .black, dark: .white),
                                        backgroundColor: .adaptable(light: .white, dark: .black))
                        .brightness(colorScheme == .light ? (!imageEnhanced || isProcessing ? -0.3 : 0.0) : (!imageEnhanced || isProcessing ? 0.3 : 0.0))
                        .disabled(!imageEnhanced || isProcessing ? true : false)
                        /*.popover(isPresented: $showingFeedbackRequest) {
                            FeedbackRequestView()
                        }*/
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                if inputImage == nil {
                    VStack {
                        Text("FotoEnhance")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .shadow(radius: 10)
                        //Text("A Magical App to Enhance Photos")
                        HStack {
                            Image(systemName: SFSymbolName(rawValue: "wand.and.stars")!)
                            Text("Magically Enhance Photos")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .shadow(radius: 10)
                        }
                    }
                }
                
                if inputImage != nil {
                    Spacer()
                }
                
                if inputImage != nil {
                    ZStack {
    
                        // MARK: Image View
                        
                        imageView?
                            .applyModifiers()
                            .gesture(MagnificationGesture()
                                .onChanged { val in
                                    let delta = val / self.lastScale
                                    self.lastScale = val
                                    let newScale = self.scale * delta
                                    self.scale = newScale
                                }
                                .onEnded { _ in
                                    self.lastScale = 1.0
                                }
                            )
                            .onLongPressGesture(minimumDuration: 0.001,
                                                maximumDistance: 10,
                                                perform: {
                                    imageView = Image(uiImage: blendedImage!)
                                    //print("long press.")
//                                }
                            },
                                                onPressingChanged: { isChanged in
                                if isChanged {
                                        imageView = Image(uiImage: inputImage!)
                                        //print("Press changed.")
//                                    }
                                }
                            })
                        
                        // MARK: Enhancement Progress View
                        
                        EnhancementProgressView()
                                .opacity(isProcessing ? 1 : 0)
                                .animation(.linear(duration: 0.125), value: isProcessing)
                        
                        // MARK: Image Save View
                        
                        ImageSaveView()
                            .opacity(imageSaved ? 1 : 0)
                            .animation(.linear(duration: 0.125), value: imageSaved)
                    }
                }
                
                Spacer()
                
                VStack {
                    HStack {
                        
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
                                enhanceImage(inputImage: image, outputImage: &enhancedImage)
//                                enhancedImage = image
                                
                                // Resize `enhancedImage` for performance optimization at the expense of memory.
                                enhancedImage1024 = enhancedImage?.resize(CGSize(width: 1024, height: 1024))
                                enhancedImage2048 = enhancedImage?.resize(CGSize(width: 2048, height: 2048))
                                
                                // Once blend after enhancement.
                                blendedImage = blend(image1: image.resize(CGSize(width: 2048, height: 2048)),
                                                     image2: enhancedImage2048!,
                                                     alpha: blendValue,
                                                     resolution: 2048)
                                
                                // Resize processed image as input image.
                                blendedImage = blendedImage?.resize(image.resizeLargerSideTo(length: 2048).size)
                                
                                // Enhance the face.
                                //enhanceFace(inputImage: enhancedImage!, outputImage: &blendedImage)
                                
                                // Display the processed image.
                                DispatchQueue.main.async {
                                    
                                    // Enhancement is completed.
                                    isProcessing = false
                                    
                                    // Image is now enhanced.
                                    imageEnhanced = true
                                    
                                    // Set the processed image to image view.
                                    imageView = Image(uiImage: blendedImage!)
                                }
                            }
                        }
                               .applyModifiers(fontSize: 18,
                                               frameSize: (130, 40),
                                               foregroundColor: .adaptable(light: .black, dark: .white),
                                               backgroundColor: .adaptable(light: .white, dark: .black))
                               .padding(.vertical, 10)
                               .brightness(colorScheme == .light ? (imageEnhanced || isProcessing || inputImage == nil ? -0.3 : 0.0) : (imageEnhanced || isProcessing || inputImage == nil ? 0.3 : 0.0))
                               .disabled(imageEnhanced || isProcessing || inputImage == nil ? true : false)
                    }
                    
                    // MARK: Blend Slider
                    
                    VStack {
                        HStack {
                            Text("ENHANCEMENT LEVEL")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                            Spacer()
                            Text("\(Int(blendValue))")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        ValueSlider(value: $blendValue,
                                    in: 0...100,
                                    step: 5) { isEditing in
                            
                            // We don't need multiple same values.
                            if oldBlendValue != blendValue {
                                
                                // Track new `blendValue`.
                                oldBlendValue = blendValue
                                
                                DispatchQueue.global(qos: .userInteractive).async {
                                    
                                    // Safely unwrap the image.
                                    guard let image = inputImage else {
                                        print("Image not found.")
                                        return
                                    }
                                    
                                    // Blend the image.
                                    blendedImage = blend(image1: image.resize(CGSize(width: 1024, height: 1024)),
                                                         image2: enhancedImage1024!,
                                                         alpha: blendValue,
                                                         resolution: 1024)
                                    
                                    // Resize blended image as input image.
                                    blendedImage = blendedImage?.resize(image.resizeLargerSideTo(length: 2048).size)
                                    
                                    // Display the processed image.
                                    DispatchQueue.main.async {
                                        
                                        // Set the processed image to image view.
                                        imageView = Image(uiImage: blendedImage!)
                                    }
                                }
                                
                                // Run haptic feedback.
                                Haptics.shared.run(.light)
                            }
                            
                            // Create full-resolution image when user lifts the finger from slider thumb.
                            if !isEditing {
                                
                                //print("isEditing: \(isEditing) | value: \(blendValue)")
                                
                                DispatchQueue.global(qos: .userInteractive).async {
                                    
                                    // Safely unwrap the image.
                                    guard let image = inputImage else {
                                        print("Image not found.")
                                        return
                                    }
                                    
                                    // Blend the image.
                                    blendedImage = blend(image1: image.resize(CGSize(width: 2048, height: 2048)),
                                                         image2: enhancedImage2048!,
                                                         alpha: blendValue,
                                                         resolution: 2048)
                                    
                                    // Resize blended image as input image.
                                    blendedImage = blendedImage?.resize(image.resizeLargerSideTo(length: 2048).size)
                                    
                                    // Display the processed image.
                                    DispatchQueue.main.async {
                                        
                                        // Set the processed image to image view.
                                        imageView = Image(uiImage: blendedImage!)
                                    }
                                }
                            }
                        }
                        .valueSliderStyle(
                            HorizontalValueSliderStyle(track: Capsule()
                                .frame(height: 6)
                                .foregroundColor(imageEnhanced ? Color(cube256: .sRGB, red: 233, green: 12, blue: 93) : .gray),
                                                       thumb: Capsule()
                                .frame(width: 16)
                                .foregroundColor(.white)
                                .shadow(radius: 6)
                            )
                        )
                        .frame(height: 40)
                        .disabled(imageEnhanced ? false : true)
                    }
                    .padding(.horizontal, 30)
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
            
            // MARK: Launch App View
            
            LaunchAppView()
                .opacity(justLaunched ? 1 : 0)
                .animation(.linear(duration: 0.35), value: justLaunched)
        }
        .onDisappear {
            releaseResources()
        }
        .onAppear {
            releaseResources()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                justLaunched = false
            }
        }
        .onShake {
            showFeedbackEmailComposer()
        }
    }
}

// MARK: Reset Methods

extension ContentView {
    
    /// Resets the blend function-related state properties to default.
    func resetBlendValues() {
        self.blendValue = 50.0
        self.oldBlendValue = 50.0
    }
    
    func releaseResources() {
        self.inputImage = nil
        self.enhancedImage = nil
        self.enhancedImage1024 = nil
        self.enhancedImage2048 = nil
        self.blendedImage = nil
        self.imageView = nil
    }
}

// MARK: Functions

func blend(image1: UIImage,
           image2: UIImage,
           alpha: Float,
           resolution: Int) -> UIImage? {

    // Adjust alpha value.
    var alpha = alpha / 100.0
    if alpha < 0.0 {
        alpha = 0.0
    } else if alpha > 1.0 {
        alpha = 1.0
    }
    print("alpha: \(alpha)")
    
    do {
        // MLModel configuration.
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all
        
        // Have to initialize it somehow.
        var blendedImage = image1.pixelBuffer!
        
        if resolution == 1024 {
            
            // Initialize blending model.
            let blendModel = try Blend1024(configuration: configuration)
            
            // Initialize input.s
            let alphaMLMultiArray = MLMultiArray(MLShapedArray<Float>(arrayLiteral: alpha))
            let input = Blend1024Input(image1: image1.pixelBuffer!,
                                       image2: image2.pixelBuffer!,
                                       alpha: alphaMLMultiArray)
            
            // Blend the images.
            blendedImage = try blendModel.prediction(input: input).blendedImage
        } else if resolution == 2048 {
            
            // Initialize blending model.
            let blendModel = try Blend2048(configuration: configuration)
            
            // Initialize input.s
            let alphaMLMultiArray = MLMultiArray(MLShapedArray<Float>(arrayLiteral: alpha))
            let input = Blend2048Input(image1: image1.pixelBuffer!,
                                       image2: image2.pixelBuffer!,
                                       alpha: alphaMLMultiArray)
            
            // Blend the images.
            blendedImage = try blendModel.prediction(input: input).blendedImage
        }
        
        // Return the blended image.
        return imageFromPixelBuffer(pixelBuffer: blendedImage)
    } catch {
        print(error)
    }
    return image1
}

// MARK: Instance Methods

extension ContentView {
    
    /// Loads the image from either photo library or camera.
    func loadImage() {
        
        guard let inputImage = inputImage else {
            return
        }
        
        blendedImage = inputImage
        imageView = Image(uiImage: inputImage)
    }
    
    /// Saves the processed image to photo library.
    func saveImage() {
        
        // Save the processed photo.
        guard let image = self.blendedImage else {
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
        imageSaver.writeToPhotoAlbum(image: image)
    }
}

func showFeedbackEmailComposer() {
    EmailHelper.shared.send(subject: "Feedback on FotoEnhance v\(Global.appVersion)",
                            body: """
                          🌱 Feature Request
                          What new feature you'd like us to add? 😊
                          
                          [Explain here]
                          
                          🐞 Bug
                          What was the incorrect/unexpected behavior of the app?
                          
                          [Explain here]
                          
                          💥 App Crash
                          What did you do that caused the app to crash?
                          
                          [Explain here]
                          
                          ♥️ We highly appreciate that you're taking time to write to us.
                          """,
                            to: ["hello@instart.ai"])
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
                .preferredColorScheme(.dark)
            //    .environment(\.locale, Locale(identifier: "ar"))
        }
    }
}
