//
//  Global.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 18/04/23.
//

import Foundation

struct Global {
    
    // MARK: App information
    
    static let appName = "Delta"
    static let appPageUrl = URL(string: "https://itunes.apple.com/app/id1633937151")!
    static let appReviewUrl = URL(string: "https://itunes.apple.com/app/id1633937151?action=write-review")!
    static var appVersion: String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return version + "(" + build + ")"
    }
}
