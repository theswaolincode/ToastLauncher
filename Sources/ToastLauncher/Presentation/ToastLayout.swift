//
//  ToastLayout.swift
//  ToastLauncher
//
//  Created by Daniel Ayala on 4/10/26.
//

import SwiftUI

/// Layout rules derived from where a toast is aligned.
enum ToastLayout {
    /// The screen edge a toast is anchored to, or `nil` when it's centered.
    ///
    /// Vertical alignment wins, so corner alignments like `.topLeading` count as `.top`.
    static func edge(for alignment: Alignment) -> Edge? {
        switch alignment.vertical {
        case .top: return .top
        case .bottom: return .bottom
        default:
            switch alignment.horizontal {
            case .leading: return .leading
            case .trailing: return .trailing
            default: return nil
            }
        }
    }

    /// Slides in from the anchored edge; centered toasts scale and fade instead.
    static func defaultTransition(for alignment: Alignment) -> AnyTransition {
        guard let edge = edge(for: alignment) else {
            return .scale(scale: 0.9).combined(with: .opacity)
        }
        return .move(edge: edge).combined(with: .opacity)
    }
}
