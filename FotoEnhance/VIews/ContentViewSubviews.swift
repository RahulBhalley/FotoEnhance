import SwiftUI

/// A view that displays a blurred background using the input or enhanced image
struct BlurredBackground: View {
    let inputImage: UIImage?
    let enhancedImage: UIImage?
    let colorScheme: ColorScheme
    
    var body: some View {
        Group {
            if let inputImage = inputImage {
                // Display the enhanced image if available, otherwise show the input image
                Image(uiImage: enhancedImage != nil ? enhancedImage! : inputImage)
                    .resizable()
            }
            // Apply a blur effect based on the current color scheme
            BlurEffectView(style: colorScheme == .light ? .light : .dark)
        }
        .ignoresSafeArea()
    }
}

/// A view that displays the top bar of the main screen
struct TopBar: View {
    // MARK: - Properties
    let inputImage: UIImage?
    let isProcessing: Bool
    let imageEnhanced: Bool
    let showingImagePicker: Binding<Bool>
    let imageSaved: Binding<Bool>
    let colorScheme: ColorScheme
    let onLibraryTap: () -> Void
    let onSaveTap: () -> Void
    
    var body: some View {
        ZStack {
            if inputImage != nil {
                Text("Delta")
                    .foregroundColor(.adaptable(light: .black, dark: .white))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .shadow(radius: 10)
            }
            
            HStack {
                // Library button
                CustomButton(title: "Library", systemImage: "camera", action: onLibraryTap,
                             fontSize: 16, frameSize: (100, 40),
                             foregroundColor: .adaptable(light: .black, dark: .white),
                             backgroundColor: .adaptable(light: .white, dark: .black),
                             isDisabled: isProcessing)
                Spacer()
                // Save button
                CustomButton(title: "Save", systemImage: "square.and.arrow.down", action: onSaveTap,
                             fontSize: 16, frameSize: (100, 40),
                             foregroundColor: .adaptable(light: .black, dark: .white),
                             backgroundColor: .adaptable(light: .white, dark: .black),
                             isDisabled: !imageEnhanced || isProcessing)
            }
            .padding(.horizontal)
        }
    }
}

/// A view that displays the welcome screen when no image is selected
struct WelcomeView: View {
    var body: some View {
        VStack {
            Text("Delta")
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .shadow(radius: 10)
            HStack {
                Image(systemName: "wand.and.stars")
                Text("Magically Enhance Photos")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .shadow(radius: 10)
            }
        }
    }
}

/// A view that displays the bottom bar of the main screen, including the enhance button and blend slider
struct BottomBar: View {
    @Binding var blendValue: Float
    let imageEnhanced: Bool
    let isProcessing: Bool
    let inputImage: UIImage?
    let onEnhanceTap: () -> Void
    let onBlendValueChange: (Bool) -> Void
    
    var body: some View {
        VStack {
            HStack {
                // Enhance button
                CustomButton(title: imageEnhanced ? EnhancementStatus.enhanced.rawValue : EnhancementStatus.notEnhanced.rawValue,
                             systemImage: "wand.and.stars",
                             action: onEnhanceTap,
                             fontSize: 18,
                             frameSize: (130, 40),
                             foregroundColor: .adaptable(light: .black, dark: .white),
                             backgroundColor: .adaptable(light: .white, dark: .black),
                             isDisabled: imageEnhanced || isProcessing || inputImage == nil)
            }
            
            // Blend slider
            BlendSlider(blendValue: $blendValue, isDisabled: !imageEnhanced, onEditingChanged: onBlendValueChange)
        }
    }
}

/// A custom button view with configurable appearance and behavior
struct CustomButton: View {
    // MARK: - Properties
    let title: String
    let systemImage: String
    let action: () -> Void
    let fontSize: CGFloat
    let frameSize: (width: CGFloat, height: CGFloat)
    let foregroundColor: Color
    let backgroundColor: Color
    let isDisabled: Bool
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
            }
        }
        .applyModifiers(fontSize: fontSize,
                        frameSize: frameSize,
                        foregroundColor: foregroundColor,
                        backgroundColor: backgroundColor)
        .brightness(isDisabled ? (foregroundColor == .black ? -0.3 : 0.3) : 0.0)
        .disabled(isDisabled)
    }
}

/// A custom slider view for adjusting the blend value
struct BlendSlider: View {
    @Binding var blendValue: Float
    let isDisabled: Bool
    let onEditingChanged: (Bool) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("ENHANCEMENT LEVEL")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Spacer()
                Text("\(Int(blendValue))")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            ValueSlider(value: $blendValue, in: 0...100, step: 5, onEditingChanged: onEditingChanged)
                .valueSliderStyle(
                    HorizontalValueSliderStyle(track: Capsule()
                        .frame(height: 6)
                        .foregroundColor(!isDisabled ? Color(cube256: .sRGB, red: 233, green: 12, blue: 93) : .gray),
                                               thumb: Capsule()
                        .frame(width: 16)
                        .foregroundColor(.white)
                        .shadow(radius: 6)
                    )
                )
                .frame(height: 40)
                .disabled(isDisabled)
        }
        .padding(.horizontal, 30)
    }
}