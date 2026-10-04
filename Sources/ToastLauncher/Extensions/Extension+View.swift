//
//  Extension+View.swift
//  SwiftUI-Components
//
//  Created by Daniel Ayala on 15/10/22.
//

import SwiftUI

extension View {
    /// Presents `content` as an overlay while `isPresented` is `true`.
    ///
    /// The original API, kept fully backward compatible: it never auto-dismisses and
    /// animates using the caller's `withAnimation`. Prefer ``toast(isPresented:alignment:duration:dragToDismiss:haptic:transition:animation:onDismiss:content:)``
    /// for new code.
    public func toastView<Content>(isPresented: Binding<Bool>, alignment: Alignment, animationStart: AnyTransition, animationEnd: AnyTransition, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        modifier(ToastModifier(
            isPresented: isPresented,
            alignment: alignment,
            transition: .asymmetric(insertion: animationStart, removal: animationEnd),
            animation: nil,
            duration: nil,
            onDismiss: onDismiss,
            isDragToDismissEnabled: false,
            haptic: nil,
            toastContent: content))
    }

    /// Presents `content` as a toast while `isPresented` is `true`.
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls visibility. The toast sets it back to `false` when it dismisses itself.
    ///   - alignment: Where the toast appears. Defaults to `.top`.
    ///   - duration: Seconds before auto-dismissing, or `nil` to stay until dismissed. Defaults to 3.
    ///     The timer pauses while the toast is being dragged.
    ///   - dragToDismiss: Whether swiping toward the toast's edge dismisses it. Centered toasts can't be dragged.
    ///   - haptic: Haptic feedback played when the toast appears, or `nil` (the default) for none.
    ///   - transition: Insertion/removal transition. Defaults to sliding from the toast's edge.
    ///   - animation: Animation used to show and hide the toast.
    ///   - onDismiss: Called after the toast is dismissed, however that happened.
    ///   - content: The toast's view.
    public func toast<Content: View>(
        isPresented: Binding<Bool>,
        alignment: Alignment = .top,
        duration: TimeInterval? = 3,
        dragToDismiss: Bool = true,
        haptic: ToastHaptic? = nil,
        transition: AnyTransition? = nil,
        animation: Animation = .spring(response: 0.4, dampingFraction: 0.8),
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(ToastModifier(
            isPresented: isPresented,
            alignment: alignment,
            transition: transition ?? ToastLayout.defaultTransition(for: alignment),
            animation: animation,
            duration: duration,
            onDismiss: onDismiss,
            isDragToDismissEnabled: dragToDismiss,
            haptic: haptic,
            toastContent: content))
    }

    /// Presents the toasts added to `queue` one after another.
    ///
    /// - Parameters:
    ///   - queue: The queue to present. Add toasts with ``ToastQueue/enqueue(duration:content:)``.
    ///   - alignment: Where toasts appear. Defaults to `.top`.
    ///   - dragToDismiss: Whether swiping toward the toast's edge dismisses it.
    ///   - haptic: Haptic feedback played when each toast appears, or `nil` (the default) for none.
    ///   - transition: Insertion/removal transition. Defaults to sliding from the toast's edge.
    ///   - animation: Animation used to show and hide each toast.
    public func toastQueue(
        _ queue: ToastQueue,
        alignment: Alignment = .top,
        dragToDismiss: Bool = true,
        haptic: ToastHaptic? = nil,
        transition: AnyTransition? = nil,
        animation: Animation = .spring(response: 0.4, dampingFraction: 0.8)
    ) -> some View {
        modifier(ToastQueueModifier(
            queue: queue,
            alignment: alignment,
            isDragToDismissEnabled: dragToDismiss,
            haptic: haptic,
            transition: transition ?? ToastLayout.defaultTransition(for: alignment),
            animation: animation))
    }
}
