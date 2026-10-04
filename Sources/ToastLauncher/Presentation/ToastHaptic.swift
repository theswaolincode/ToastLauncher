//
//  ToastHaptic.swift
//  ToastLauncher
//
//  Created by Daniel Ayala on 4/10/26.
//

import SwiftUI
import UIKit

/// Haptic feedback played when a toast appears.
///
/// Pass one to the `haptic` parameter of
/// ``SwiftUI/View/toast(isPresented:alignment:duration:dragToDismiss:haptic:transition:animation:onDismiss:content:)``
/// or ``SwiftUI/View/toastQueue(_:alignment:dragToDismiss:haptic:transition:animation:)``.
/// Haptics play on iPhone only; the Simulator doesn't play them.
public enum ToastHaptic: Sendable {
    /// Indicates that a task completed successfully.
    case success
    /// Indicates that a task produced a warning.
    case warning
    /// Indicates that a task failed.
    case error

    @available(iOS 17.0, *)
    var sensoryFeedback: SensoryFeedback {
        switch self {
        case .success: return .success
        case .warning: return .warning
        case .error: return .error
        }
    }

    var notificationType: UINotificationFeedbackGenerator.FeedbackType {
        switch self {
        case .success: return .success
        case .warning: return .warning
        case .error: return .error
        }
    }
}

/// Plays `haptic` each time `isPresented` becomes `true`.
struct ToastHapticModifier: ViewModifier {
    let haptic: ToastHaptic?
    let isPresented: Bool

    func body(content: Content) -> some View {
        if let haptic {
            if #available(iOS 17.0, *) {
                // Declarative and tied to the view's lifecycle; the system handles generator preparation.
                content.sensoryFeedback(haptic.sensoryFeedback, trigger: isPresented) { _, presented in
                    presented
                }
            } else {
                content.onChange(of: isPresented) { presented in
                    guard presented else { return }
                    UINotificationFeedbackGenerator().notificationOccurred(haptic.notificationType)
                }
            }
        } else {
            content
        }
    }
}
