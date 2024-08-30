import SwiftUI
import CoreML
import Vision

/// The main view of the FotoEnhance app, responsible for managing the image enhancement process.
struct ContentView: View {
    // MARK: - Environment Properties
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Image Properties
    /// The current image view displayed to the user.
    @State private var imageView: Image?
    /// The original input image selected by the user.
    @State private var inputImage: UIImage?
    /// The enhanced version of the input image.
    @State private var enhancedImage: UIImage?
    /// A 1024x1024 version of the enhanced image for faster processing.
    @State private var enhancedImage1024: UIImage?
    /// A 2048x2048 version of the enhanced image for higher quality.
    @State private var enhancedImage2048: UIImage?
    /// The result of blending the input and enhanced images.
    @State private var blendedImage: UIImage?
    
    // MARK: - UI State Properties
    /// Controls the visibility of the image picker.
    @State private var showingImagePicker = false
    /// Controls the visibility of alert messages.
    @State private var showingAlert = false
    /// Controls the visibility of the subscription view.
    @State private var showingSubscription = false
    /// Indicates whether the current image has been enhanced.
    @State private var imageEnhanced = false
    /// Indicates whether the current image has been saved.
    @State private var imageSaved = false
    /// Indicates whether image processing is in progress.
    @State private var isProcessing = false
    /// Indicates whether the app has just launched.
    @State private var justLaunched = true
    
    // MARK: - Slider Properties
    /// The current value of the blend slider.
    @State private var blendValue: Float = 50
    /// The previous value of the blend slider, used for change detection.
    @State private var oldBlendValue: Float = 50
    
    // MARK: - Zoom Properties
    /// The current zoom scale of the image.
    @State private var scale: CGFloat = 1.0
    /// The previous zoom scale, used for change detection.
    @State private var lastScale: CGFloat = 1.0
    
    // MARK: - Device Properties
    /// The current device running the app.
    private let device = Device.current
    /// The resolution to use for image processing based on the device.
    var resolution: Int {
        Device.current == .iPhone13 ? 2048 : 1024
    }
    
    var body: some View {
        ZStack {
            // Display the blurred background
            BlurredBackground(inputImage: inputImage, enhancedImage: enhancedImage, colorScheme: colorScheme)
            
            VStack {
                // Display the top bar with library and save buttons
                TopBar(inputImage: inputImage, isProcessing: isProcessing, imageEnhanced: imageEnhanced,
                       showingImagePicker: $showingImagePicker, imageSaved: $imageSaved, colorScheme: colorScheme,
                       onLibraryTap: { showingImagePicker = true; imageEnhanced = false; enhancedImage = nil },
                       onSaveTap: saveImage)
                
                Spacer()
                
                // Display either the welcome view or the current image
                if inputImage == nil {
                    WelcomeView()
                } else {
                    Spacer()
                    imageView
                }
                
                Spacer()
                
                // Display the bottom bar with enhance button and blend slider
                BottomBar(blendValue: $blendValue, imageEnhanced: imageEnhanced, isProcessing: isProcessing,
                          inputImage: inputImage, onEnhanceTap: enhanceImage, onBlendValueChange: handleBlendValueChange)
            }
            .padding(.vertical)
            
            // Display the launch view when the app starts
            LaunchAppView()
                .opacity(justLaunched ? 1 : 0)
                .animation(.linear(duration: 0.35), value: justLaunched)
        }
        .onDisappear(perform: releaseResources)
        .onAppear(perform: setupInitialState)
        .onShake(perform: showFeedbackEmailComposer)
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage, sourceType: .photoLibrary)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Handles changes in the blend slider value.
    /// - Parameter isEditing: Indicates whether the user is currently editing the slider.
    private func handleBlendValueChange(isEditing: Bool) {
        if oldBlendValue != blendValue {
            oldBlendValue = blendValue
            // Blend images with appropriate resolution based on editing state
            ImageViewHelpers.blendImages(inputImage: inputImage, enhancedImage1024: enhancedImage1024,
                                         enhancedImage2048: enhancedImage2048, blendValue: blendValue,
                                         resolution: isEditing ? 1024 : 2048) { blendedImage in
                self.blendedImage = blendedImage
                self.imageView = Image(uiImage: blendedImage!)
            }
            Haptics.shared.run(.light)
        }
    }
    
    /// Initiates the image enhancement process.
    private func enhanceImage() {
        isProcessing = true
        ImageViewHelpers.enhanceImage(inputImage: inputImage!) { enhancedImage, enhancedImage1024, enhancedImage2048 in
            self.enhancedImage = enhancedImage
            self.enhancedImage1024 = enhancedImage1024
            self.enhancedImage2048 = enhancedImage2048
            
            // Blend the enhanced image with the original
            ImageViewHelpers.blendImages(inputImage: self.inputImage, enhancedImage1024: self.enhancedImage1024,
                                         enhancedImage2048: self.enhancedImage2048, blendValue: self.blendValue,
                                         resolution: 2048) { blendedImage in
                self.blendedImage = blendedImage
                self.isProcessing = false
                self.imageEnhanced = true
                self.imageView = Image(uiImage: blendedImage!)
            }
        }
    }
    
    /// Loads the selected image from the image picker.
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        blendedImage = inputImage
        imageView = Image(uiImage: inputImage)
    }
    
    /// Saves the current blended image to the photo library.
    private func saveImage() {
        guard let image = self.blendedImage else { return }
        
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            imageSaved = true
            // Reset the saved state after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                imageSaved = false
            }
            // Provide haptic feedback
            Haptics.shared.run(.heavy)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.125) {
                Haptics.shared.run(.heavy)
            }
        }
        
        imageSaver.errorHandler = { error in
            showingAlert = true
            print("Error: \(error.localizedDescription)")
        }
        
        imageSaver.writeToPhotoAlbum(image: image)
    }
    
    /// Releases all image-related resources.
    private func releaseResources() {
        inputImage = nil
        enhancedImage = nil
        enhancedImage1024 = nil
        enhancedImage2048 = nil
        blendedImage = nil
        imageView = nil
    }
    
    /// Sets up the initial state of the view.
    private func setupInitialState() {
        releaseResources()
        
        // Hide the launch view after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            justLaunched = false
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
