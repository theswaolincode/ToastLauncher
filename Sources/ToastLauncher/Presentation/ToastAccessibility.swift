//
//  ToastAccessibility.swift
//  ToastLauncher
//
//  Created by Daniel Ayala on 4/10/26.
//

import SwiftUI
import UIKit

extension View {
    /// Has VoiceOver announce `message` when this view appears.
    ///
    /// Apply it to custom toast content so VoiceOver users hear the toast without having
    /// to find it on screen. ``ToastView`` already announces its title.
    ///
    /// ```swift
    /// .toast(isPresented: $saved) {
    ///     MyToast().toastAnnouncement("Saved")
    /// }
    /// ```
    ///
    /// - Parameter message: A localized, human-readable message.
    public func toastAnnouncement(_ message: String) -> some View {
        onAppear { ToastAnnouncer.announce(message) }
    }
}

enum ToastAnnouncer {
    @MainActor
    static func announce(_ message: String) {
        guard !message.isEmpty else { return }
        // Queue behind whatever VoiceOver is saying (e.g. the button that triggered the toast)
        // instead of cutting it off — a toast is a status message, not an alert.
        let text = NSAttributedString(string: message, attributes: [.accessibilitySpeechQueueAnnouncement: true])
        if #available(iOS 17.0, *) {
            AccessibilityNotification.Announcement(text).post()
        } else {
            UIAccessibility.post(notification: .announcement, argument: text)
        }
    }
}
