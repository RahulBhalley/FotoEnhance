//
//  Global.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 18/04/23.
//

import Foundation

/// A structure containing global constants and computed properties for the application.
struct Global {
    
    // MARK: - App Information
    
    /// The name of the application.
    static let appName = "Delta"
    
    /// The URL for the app's page on the App Store.
    static let appPageUrl = URL(string: "https://itunes.apple.com/app/id1633937151")!
    
    /// The URL for writing a review for the app on the App Store.
    static let appReviewUrl = URL(string: "https://itunes.apple.com/app/id1633937151?action=write-review")!
    
    /// The current version and build number of the application.
    static var appVersion: String {
        // Retrieve the main bundle's information dictionary
        guard let infoDict = Bundle.main.infoDictionary else {
            return "Unknown Version"
        }
        
        // Extract version and build number
        let version = infoDict["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = infoDict["CFBundleVersion"] as? String ?? "Unknown"
        
        // Combine version and build number
        return "\(version) (\(build))"
    }
    
    // MARK: - Feature Flags
    
    /// Indicates whether the pro features are enabled.
    static var isProEnabled: Bool {
        // TODO: Implement logic to check if pro features are enabled
        return false
    }
    
    // MARK: - App Settings
    
    /// The maximum number of recent images to display.
    static let maxRecentImages = 10
    
    /// The default image quality for saving processed images.
    static let defaultImageQuality: CGFloat = 0.8
    
    // MARK: - UI Constants
    
    /// Standard corner radius for UI elements.
    static let cornerRadius: CGFloat = 10
    
    /// Standard padding for UI elements.
    static let standardPadding: CGFloat = 16
    
    // MARK: - Networking
    
    /// Base URL for API requests.
    static let apiBaseUrl = URL(string: "https://api.example.com")!
    
    /// Timeout interval for network requests.
    static let networkTimeoutInterval: TimeInterval = 30
}

// MARK: - Helper Extensions

extension Global {
    /// Formats a date to a string using the specified format.
    /// - Parameters:
    ///   - date: The date to format.
    ///   - format: The desired format string (default is "yyyy-MM-dd").
    /// - Returns: A formatted date string.
    static func formatDate(_ date: Date, format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    /// Generates a unique identifier string.
    /// - Returns: A unique identifier string.
    static func generateUniqueId() -> String {
        return UUID().uuidString
    }
}
