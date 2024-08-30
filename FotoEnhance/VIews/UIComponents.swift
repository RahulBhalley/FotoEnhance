import SwiftUI

/// A custom button view with configurable appearance and behavior
struct CustomButton: View {
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