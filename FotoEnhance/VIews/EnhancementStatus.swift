import Foundation

/// Enum representing the enhancement status of an image
enum EnhancementStatus: String {
    /// Indicates that the image has been enhanced
    case enhanced = "Enhanced"
    
    /// Indicates that the image has not been enhanced and is ready for enhancement
    case notEnhanced = "Enhance"
}