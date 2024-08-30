//
//  ShakeDetector.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 17/09/23.
//

import SwiftUI
import UIKit

// MARK: - UIDevice Extension

extension UIDevice {
    /// Custom notification name for device shake events.
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

// MARK: - UIWindow Extension

extension UIWindow {
    /// Overrides the default motion ended event to post a custom notification when the device is shaken.
    /// - Parameters:
    ///   - motion: The type of motion that ended.
    ///   - event: The event associated with the motion.
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            // Post a notification when a shake motion is detected
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

// MARK: - ShakeDetector

/// A view modifier that detects shake gestures and triggers an action.
struct ShakeDetector: ViewModifier {
    /// The action to perform when a shake is detected.
    let action: () -> Void
    
    /// Applies the shake detection modifier to the content.
    /// - Parameter content: The content to which the modifier is applied.
    /// - Returns: A view that triggers the action when a shake is detected.
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                // Execute the action when a shake notification is received
                action()
            }
    }
}

// MARK: - View Extension

extension View {
    /// Adds shake gesture detection to a view.
    /// - Parameter action: The closure to execute when a shake is detected.
    /// - Returns: A view that responds to shake gestures.
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(ShakeDetector(action: action))
    }
}
