//
//  Haptics.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 24/07/22.
//

import UIKit

class Haptics {
    static let shared = Haptics()
    
    private init() { }
    
    func run(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    func notify(_ feedbackStyle: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackStyle)
    }
}
