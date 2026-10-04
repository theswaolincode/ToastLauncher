//
//  ToastBackground.swift
//  ToastLauncher
//
//  Created by Daniel Ayala on 4/10/26.
//

import SwiftUI

/// Built-in backgrounds for toast content.
public enum ToastBackgroundStyle: Sendable {
    /// Liquid Glass on iOS 26 and later; a translucent material on earlier versions.
    case glass
    /// A translucent system material on every version.
    case material
    /// An opaque background that adapts to light and dark mode.
    case solid
}

extension View {
    /// Places a built-in toast background behind this view.
    ///
    /// Works with any content, so custom toasts can match the built-in look:
    ///
    /// ```swift
    /// .toast(isPresented: $saved) {
    ///     Label("Saved", systemImage: "checkmark.circle.fill")
    ///         .padding()
    ///         .toastBackground(.glass)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - style: The background to use. Defaults to ``ToastBackgroundStyle/glass``.
    ///   - cornerRadius: The corner radius of the background shape.
    public func toastBackground(_ style: ToastBackgroundStyle = .glass, cornerRadius: CGFloat = 16) -> some View {
        modifier(ToastBackgroundModifier(style: style, cornerRadius: cornerRadius))
    }
}

struct ToastBackgroundModifier: ViewModifier {
    let style: ToastBackgroundStyle
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        // `.continuous` corners match the system's own rounded shapes.
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        // No Reduce Transparency branch needed: both Liquid Glass and system materials
        // already become more opaque on their own when that setting is on.
        switch style {
        case .glass:
            if #available(iOS 26.0, *) {
                // `.interactive()` makes the glass respond to touch, which suits a draggable toast.
                content.glassEffect(.regular.interactive(), in: shape)
            } else {
                content.background(.regularMaterial, in: shape)
            }
        case .material:
            content.background(.regularMaterial, in: shape)
        case .solid:
            content.background(Color(.secondarySystemGroupedBackground), in: shape)
        }
    }
}

#Preview("Toast backgrounds") {
    let styles: [(String, ToastBackgroundStyle)] = [("Glass", .glass), ("Material", .material), ("Solid", .solid)]
    VStack(spacing: 24) {
        ForEach(styles, id: \.0) { name, style in
            Label("\(name) background", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .toastBackground(style)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    // A busy backdrop makes the difference between the styles visible.
    .background(LinearGradient(colors: [.orange, .pink, .purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
}
