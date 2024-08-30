//
//  FotoEnhanceApp.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 12/07/22.
//

import SwiftUI

/// The main entry point for the FotoEnhance application.
@main
struct FotoEnhanceApp: App {
    
    /// The app delegate responsible for setting up Firebase.
    ///
    /// This property uses the `@UIApplicationDelegateAdaptor` property wrapper to integrate
    /// the `AppDelegate` into the SwiftUI app lifecycle.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    /// The body of the app, defining the app's scene structure.
    var body: some Scene {
        /// Creates a window group containing the main content view of the app.
        WindowGroup {
            /// The main content view of the application.
            ContentView()
        }
    }
}
