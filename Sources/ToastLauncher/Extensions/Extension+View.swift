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
    /// animates using the caller's `withAnimation`. Prefer ``toast(isPresented:alignment:duration:transition:animation:onDismiss:content:)``
    /// for new code.
    public func toastView<Content>(isPresented: Binding<Bool>, alignment: Alignment, animationStart: AnyTransition, animationEnd: AnyTransition, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        modifier(ToastModifier(
            isPresented: isPresented,
            alignment: alignment,
            transition: .asymmetric(insertion: animationStart, removal: animationEnd),
            animation: nil,
            duration: nil,
            onDismiss: onDismiss,
            toastContent: content))
    }

    /// Presents `content` as a toast while `isPresented` is `true`.
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls visibility. The toast sets it back to `false` when it dismisses itself.
    ///   - alignment: Where the toast appears. Defaults to `.top`.
    ///   - duration: Seconds before auto-dismissing, or `nil` to stay until dismissed. Defaults to 3.
    ///   - transition: Insertion/removal transition. Defaults to sliding from the toast's edge.
    ///   - animation: Animation used to show and hide the toast.
    ///   - onDismiss: Called after the toast is dismissed, however that happened.
    ///   - content: The toast's view.
    public func toast<Content: View>(
        isPresented: Binding<Bool>,
        alignment: Alignment = .top,
        duration: TimeInterval? = 3,
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
            toastContent: content))
    }
}
