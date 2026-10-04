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
    let isDragToDismissEnabled: Bool
    let toastContent: () -> ToastContent

    /// `@GestureState` (not `@State`) so it resets even if the system cancels the gesture,
    /// and the reset transaction gives us the spring-back for free.
    @GestureState(resetTransaction: Transaction(animation: .spring(response: 0.3, dampingFraction: 0.7)))
    private var dragTranslation: CGSize = .zero

    private var edge: Edge? { ToastLayout.edge(for: alignment) }

    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                // The container always exists so SwiftUI can run the removal transition.
                ZStack {
                    if isPresented {
                        toastContent()
                            .offset(ToastDrag.offset(for: dragTranslation, toward: edge))
                            // `.subviews` disables only this gesture; the content's own gestures keep working.
                            .gesture(dragGesture, including: isDragToDismissEnabled ? .all : .subviews)
                            .transition(transition)
                    }
                }
                .animation(ifPresent: animation, value: isPresented)
            }
            // Restarts whenever the key changes, and SwiftUI cancels the previous run, so an
            // early dismissal never leaves a stale timer behind. Including `isDragging` pauses
            // the timer while the toast is held and restarts it after a spring-back.
            .task(id: AutoDismissKey(isPresented: isPresented, isDragging: dragTranslation != .zero)) {
                guard isPresented, dragTranslation == .zero else { return }
                if await ToastAutoDismiss.wait(for: duration) {
                    dismiss()
                }
            }
            // Same semantics as `.sheet(onDismiss:)`: fires however the toast went away.
            .onChange(of: isPresented) { presented in
                if !presented { onDismiss?() }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragTranslation) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                if ToastDrag.shouldDismiss(predictedEndTranslation: value.predictedEndTranslation, toward: edge) {
                    dismiss()
                }
            }
    }

    private func dismiss() {
        withAnimation(animation ?? .default) {
            isPresented = false
        }
    }
}

private struct AutoDismissKey: Equatable {
    let isPresented: Bool
    let isDragging: Bool
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
