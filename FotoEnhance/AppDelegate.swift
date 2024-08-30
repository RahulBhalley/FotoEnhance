//
//  AppDelegate.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 18/04/23.
//

import Firebase
import SwiftUI
import UserNotifications

/// The app delegate class responsible for handling application lifecycle events and configuring app-wide services.
class AppDelegate: NSObject, UIApplicationDelegate {
    
    /// The key used to identify the message ID in push notifications.
    let gcmMessageIDKey = "gcm.message_id"
    
    /// Called when the application finishes launching.
    /// - Parameters:
    ///   - application: The singleton app object.
    ///   - launchOptions: A dictionary indicating the reason the app was launched (if any).
    /// - Returns: `false` if the app cannot handle the URL resource or continue a user activity, otherwise return `true`.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Set up Firebase Cloud Messaging
        Messaging.messaging().delegate = self
        
        // Configure push notifications
        setupPushNotifications(application)
        
        return true
    }
    
    /// Sets up push notifications for the application.
    /// - Parameter application: The singleton app object.
    private func setupPushNotifications(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 and above
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in })
        } else {
            // For iOS 9 and below
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    /// Called when the app receives a remote notification.
    /// - Parameters:
    ///   - application: The singleton app object.
    ///   - userInfo: A dictionary that contains information related to the remote notification.
    ///   - completionHandler: A handler to execute when the download operation is complete.
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // Log the message ID if present
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print the full notification payload for debugging
        print(userInfo)
        
        // Inform the system that new data was fetched
        completionHandler(UIBackgroundFetchResult.newData)
        
        // Optionally reset the badge number
        // UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    /// Called when the application becomes active.
    /// - Parameter application: The singleton app object.
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Perform any necessary tasks when the app becomes active
    }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
    /// Called when a new FCM token is generated.
    /// - Parameters:
    ///   - messaging: The messaging object.
    ///   - fcmToken: The new token.
    func messaging(_ messaging: Messaging,
                   didReceiveRegistrationToken fcmToken: String?) {
        
        let deviceToken: [String: String] = ["token": fcmToken ?? ""]
        print("Device token: ", deviceToken) // This token can be used for testing notifications on FCM
        // TODO: Send this token to your server for targeted push notifications
    }
}

// MARK: - UNUserNotificationCenterDelegate

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /// Called when a notification is about to be presented while the app is in the foreground.
    /// - Parameters:
    ///   - center: The shared user notification center object.
    ///   - notification: The notification that is about to be delivered.
    ///   - completionHandler: The block to execute with the presentation options for the notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // Log the message ID if present
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print the full notification payload for debugging
        print(userInfo)
        
        // Specify how to present the notification when the app is in the foreground
        completionHandler([[.banner, .badge, .sound]])
    }
    
    /// Called when the app successfully registers for remote notifications.
    /// - Parameters:
    ///   - application: The singleton app object.
    ///   - deviceToken: A token that identifies the device to APNs.
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Handle successful registration for remote notifications
    }
    
    /// Called when the app fails to register for remote notifications.
    /// - Parameters:
    ///   - application: The singleton app object.
    ///   - error: An error object that encapsulates information why registration did not succeed.
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Handle failed registration for remote notifications
    }
    
    /// Called when the user responds to a delivered notification.
    /// - Parameters:
    ///   - center: The shared user notification center object.
    ///   - response: The user's response to the notification.
    ///   - completionHandler: The block to execute when you have finished processing the user's response.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Log the message ID if present
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID from userNotificationCenter didReceive: \(messageID)")
        }
        
        // Print the full notification payload for debugging
        print(userInfo)
        
        completionHandler()
    }
}
