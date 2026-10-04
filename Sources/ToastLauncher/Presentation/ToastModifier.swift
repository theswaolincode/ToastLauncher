//
//  ToastModifier.swift
//  ToastLauncher
//
//  Created by Daniel Ayala on 4/10/26.
//

import SwiftUI

/// Shared implementation behind `toastView(...)` and `toast(...)`.
struct ToastModifier<ToastContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let alignment: Alignment
    let transition: AnyTransition
    /// `nil` means "use whatever animation the caller's transaction carries".
    let animation: Animation?
    /// `nil` means the toast stays until dismissed.
    let duration: TimeInterval?
    /// Plain closure like `.sheet(onDismiss:)`: it's created and called on the main actor anyway.
    let onDismiss: (() -> Void)?
    let toastContent: () -> ToastContent

    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                // The container always exists so SwiftUI can run the removal transition.
                ZStack {
                    if isPresented {
                        toastContent()
                            .transition(transition)
                    }
                }
                .animation(ifPresent: animation, value: isPresented)
            }
            // Restarts whenever `isPresented` flips, and SwiftUI cancels the previous run,
            // so an early dismissal (or re-presentation) never leaves a stale timer behind.
            .task(id: isPresented) {
                guard isPresented else { return }
                if await ToastAutoDismiss.wait(for: duration) {
                    dismiss()
                }
            }
            // Same semantics as `.sheet(onDismiss:)`: fires however the toast went away.
            .onChange(of: isPresented) { presented in
                if !presented { onDismiss?() }
            }
    }

    private func dismiss() {
        withAnimation(animation ?? .default) {
            isPresented = false
        }
    }
}

private extension View {
    /// Applies `animation` only when non-nil. `.animation(nil, value:)` would actively
    /// strip the animation from the caller's `withAnimation`, which we don't want.
    @ViewBuilder
    func animation<V: Equatable>(ifPresent animation: Animation?, value: V) -> some View {
        if let animation {
            self.animation(animation, value: value)
        } else {
            self
        }
    }
}
