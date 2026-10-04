//
//  ToastQueueModifier.swift
//  ToastLauncher
//
//  Created by Daniel Ayala on 4/10/26.
//

import SwiftUI

/// Presents a ``ToastQueue``'s current toast through the regular `ToastModifier`,
/// so queued toasts get the same timer, drag and animation behaviour as single ones.
struct ToastQueueModifier: ViewModifier {
    @ObservedObject var queue: ToastQueue
    let alignment: Alignment
    let isDragToDismissEnabled: Bool
    let haptic: ToastHaptic?
    let transition: AnyTransition
    let animation: Animation

    func body(content: Content) -> some View {
        content.modifier(ToastModifier(
            isPresented: Binding(
                get: { queue.current != nil },
                set: { if !$0 { queue.dismissCurrent() } }
            ),
            alignment: alignment,
            transition: transition,
            animation: animation,
            duration: queue.current?.duration,
            onDismiss: nil,
            isDragToDismissEnabled: isDragToDismissEnabled,
            haptic: haptic,
            toastContent: { queue.current?.content }
        ))
    }
}
