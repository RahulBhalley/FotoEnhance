//
//  Haptics.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 24/07/22.
//

import UIKit

/// A utility class for generating haptic feedback in the app.
class Haptics {
    
    // MARK: - Singleton
    
    /// The shared instance of the Haptics class.
    static let shared = Haptics()
    
    // MARK: - Initialization
    
    /// Private initializer to ensure singleton usage.
    private init() {}
    
    // MARK: - Public Methods
    
    /// Generates haptic feedback with the specified impact style.
    /// - Parameter feedbackStyle: The style of impact feedback to generate.
    func impact(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        // Create and trigger an impact feedback generator
        let generator = UIImpactFeedbackGenerator(style: feedbackStyle)
        generator.prepare() // Reduce latency by preparing the generator
        generator.impactOccurred()
    }
    
    /// Generates a notification haptic feedback with the specified type.
    /// - Parameter feedbackType: The type of notification feedback to generate.
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        // Create and trigger a notification feedback generator
        let generator = UINotificationFeedbackGenerator()
        generator.prepare() // Reduce latency by preparing the generator
        generator.notificationOccurred(feedbackType)
    }
    
    /// Generates a selection haptic feedback.
    func selection() {
        // Create and trigger a selection feedback generator
        let generator = UISelectionFeedbackGenerator()
        generator.prepare() // Reduce latency by preparing the generator
        generator.selectionChanged()
    }
}

// MARK: - Convenience Methods

extension Haptics {
    /// Generates a light impact haptic feedback.
    func lightImpact() {
        impact(.light)
    }
    
    /// Generates a medium impact haptic feedback.
    func mediumImpact() {
        impact(.medium)
    }
    
    /// Generates a heavy impact haptic feedback.
    func heavyImpact() {
        impact(.heavy)
    }
    
    /// Generates a success notification haptic feedback.
    func success() {
        notify(.success)
    }
    
    /// Generates a warning notification haptic feedback.
    func warning() {
        notify(.warning)
    }
    
    /// Generates an error notification haptic feedback.
    func error() {
        notify(.error)
    }
}

// MARK: - Usage Example

extension Haptics {
    /// Demonstrates how to use the Haptics class.
    static func example() {
        // Using the shared instance
        let haptics = Haptics.shared
        
        // Generate different types of haptic feedback
        haptics.lightImpact()
        haptics.mediumImpact()
        haptics.heavyImpact()
        haptics.success()
        haptics.warning()
        haptics.error()
        haptics.selection()
        
        // Using custom impact and notification types
        haptics.impact(.rigid)
        haptics.notify(.success)
    }
}
