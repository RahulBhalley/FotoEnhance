//
//  EmailHelper.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 15/07/22.
//

import SwiftUI
import MessageUI

/// A helper class for handling email-related operations.
class EmailHelper: NSObject {
    /// Shared instance of EmailHelper (Singleton).
    static let shared = EmailHelper()
    
    private override init() {}
}

extension EmailHelper {
    
    /// Attempts to send an email using the device's mail capabilities.
    /// If the default Mail app is not available, it tries to use other email clients.
    /// - Parameters:
    ///   - subject: The subject of the email.
    ///   - body: The body content of the email.
    ///   - recipients: An array of email addresses to send the email to.
    func send(subject: String, body: String, to recipients: [String]) {
        guard let viewController = self.topViewController() else {
            print("Unable to find top view controller")
            return
        }
        
        if MFMailComposeViewController.canSendMail() {
            self.presentMailComposer(subject: subject, body: body, to: recipients, on: viewController)
        } else {
            self.handleExternalMailClients(subject: subject, body: body, to: recipients, on: viewController)
        }
    }
    
    /// Presents the mail composer interface if available.
    /// - Parameters:
    ///   - subject: The subject of the email.
    ///   - body: The body content of the email.
    ///   - recipients: An array of email addresses to send the email to.
    ///   - viewController: The view controller to present the mail composer on.
    private func presentMailComposer(subject: String, body: String, to recipients: [String], on viewController: UIViewController) {
        let mailComposer = MFMailComposeViewController()
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(body, isHTML: false)
        mailComposer.setToRecipients(recipients)
        mailComposer.mailComposeDelegate = self
        
        viewController.present(mailComposer, animated: true, completion: nil)
    }
    
    /// Handles the case when the default Mail app is not available by offering external mail client options.
    /// - Parameters:
    ///   - subject: The subject of the email.
    ///   - body: The body content of the email.
    ///   - recipients: An array of email addresses to send the email to.
    ///   - viewController: The view controller to present alerts on.
    private func handleExternalMailClients(subject: String, body: String, to recipients: [String], on viewController: UIViewController) {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let recipientsString = recipients.joined(separator: ",")
        
        let alert = UIAlertController(title: "Cannot open Mail", message: "", preferredStyle: .actionSheet)
        
        var haveExternalMailbox = false
        
        if let url = createEmailUrl(to: recipientsString, subject: subjectEncoded, body: bodyEncoded),
           UIApplication.shared.canOpenURL(url) {
            haveExternalMailbox = true
            alert.addAction(UIAlertAction(title: "Use External Mail App", style: .default) { _ in
                UIApplication.shared.open(url)
            })
        }
        
        if haveExternalMailbox {
            alert.message = "Would you like to open an external mailbox?"
        } else {
            alert.message = "Please set up a mail account in Settings before using the mail service."
            
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(settingsUrl) {
                alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                    UIApplication.shared.open(settingsUrl)
                })
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    /// Creates a URL for opening an external email client.
    /// - Parameters:
    ///   - recipients: A comma-separated string of email recipients.
    ///   - subject: The URL-encoded subject of the email.
    ///   - body: The URL-encoded body of the email.
    /// - Returns: A URL to open an external email client, if available.
    private func createEmailUrl(to recipients: String, subject: String, body: String) -> URL? {
        let urlSchemes = [
            "googlegmail://co?to=\(recipients)&subject=\(subject)&body=\(body)",
            "ms-outlook://compose?to=\(recipients)&subject=\(subject)",
            "ymail://mail/compose?to=\(recipients)&subject=\(subject)&body=\(body)",
            "readdle-spark://compose?recipient=\(recipients)&subject=\(subject)&body=\(body)",
            "mailto:\(recipients)?subject=\(subject)&body=\(body)"
        ]
        
        for scheme in urlSchemes {
            if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                return url
            }
        }
        
        return nil
    }
    
    /// Retrieves the topmost view controller in the app's window hierarchy.
    /// - Returns: The topmost UIViewController, if available.
    private func topViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        
        var topController = window.rootViewController
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        
        return topController
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension EmailHelper: MFMailComposeViewControllerDelegate {
    /// Dismisses the mail compose view controller when finished.
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
