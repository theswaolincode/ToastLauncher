//
//  ToastHaptic.swift
//  ToastLauncher
//
//  Created by Daniel Ayala on 4/10/26.
//

import SwiftUI
import UIKit

/// Haptic feedback played when a toast appears.
public enum ToastHaptic: Sendable {
    case success
    case warning
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
