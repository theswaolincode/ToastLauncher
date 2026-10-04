//
//  ToastView.swift
//  SwiftUI-Components
//
//  Created by Daniel Ayala on 16/10/22.
//

import SwiftUI

/// A ready-made toast with an icon, a message, and an optional dismiss button.
///
/// Present it with ``SwiftUI/View/toast(isPresented:alignment:duration:dragToDismiss:haptic:transition:animation:onDismiss:content:)``
/// or use it as a starting point for your own design. It scales with Dynamic Type and
/// announces its title to VoiceOver when it appears.
///
/// ```swift
/// ToastView(title: "Saved", symbolName: "checkmark.circle.fill", background: .glass, style: .auto) {
///     isSaved = false
/// }
/// ```
@MainActor
public struct ToastView: View {
    var title: String
    var symbolName: String
    var buttonTitle: String
    var background: ToastBackgroundStyle
    var style: ToastViewStyle
    var onDismiss: @MainActor () -> Void

    /// Creates a toast view.
    ///
    /// - Parameters:
    ///   - title: The message to show and announce to VoiceOver.
    ///   - symbolName: The SF Symbol shown above the message.
    ///   - buttonTitle: The dismiss button's title, shown for ``ToastViewStyle/prominent``.
    ///   - background: Defaults to ``ToastBackgroundStyle/solid``, the original look.
    ///   - style: Whether the toast dismisses itself or shows a dismiss button.
    ///   - onDismiss: Called when the toast asks to be dismissed. Set your presentation binding to `false` here.
   public init(title: String? = nil, symbolName: String? = nil, buttonTitle: String? = nil, background: ToastBackgroundStyle = .solid, style: ToastViewStyle, onDismiss: @escaping @MainActor () -> Void) {
        self.title = title ?? "Hello, world!!"
        self.symbolName = symbolName ?? "globe"
        self.buttonTitle = buttonTitle ?? "Dismiss Me"
        self.background = background
        self.style = style
        self.onDismiss = onDismiss
    }

    // Spacing and padding grow with the user's text size so large text doesn't feel cramped.
    @ScaledMetric(relativeTo: .body) private var spacing: CGFloat = 8
    @ScaledMetric(relativeTo: .body) private var contentPadding: CGFloat = 16
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    public var body: some View {
        VStack(spacing: spacing) {
            Image(systemName: symbolName)
                // A text style (not a fixed size) so the symbol scales with Dynamic Type.
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                // Decorative: the title already says what happened.
                .accessibilityHidden(true)
            Text(title)
                .font(.body)
                .multilineTextAlignment(.center)
                // Wrap onto more lines at large sizes instead of truncating.
                .fixedSize(horizontal: false, vertical: true)
            buildActionButton()
        }
        .toastAnnouncement(title)
        .task {
            await autoDismiss()
        }
        .padding(contentPadding)
        .frame(maxWidth: .infinity)
        .toastBackground(background, cornerRadius: cornerRadius)
        .padding()
    }

    /// The solid style keeps its original 8pt corners; translucent styles use the
    /// larger radius that suits Liquid Glass and materials.
    private var cornerRadius: CGFloat {
        background == .solid ? 8 : 16
    }

    private func autoDismiss() async {
        guard style == .auto else { return }
        let duration = ToastAutoDismiss.effectiveDuration(2, voiceOverEnabled: voiceOverEnabled)
        // `wait` returns `false` if `.task` was cancelled because the view disappeared
        // (e.g. dismissed early), so we never fire a second, stale dismissal.
        if await ToastAutoDismiss.wait(for: duration) {
            onDismiss()
        }
    }
    
    @ViewBuilder func buildActionButton() -> some View {
        if style == .prominent {
            Button(buttonTitle) { onDismiss() }
                .buttonStyle(.borderedProminent)
        }
    }
    
    /// How a ``ToastView`` is dismissed.
   public enum ToastViewStyle: Sendable {
        /// Calls `onDismiss` after 2 seconds (at least 10 while VoiceOver is running).
        case auto
        /// Shows a button that calls `onDismiss`.
        case prominent
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        ToastView(style: .prominent, onDismiss: {})
            .previewLayout(.sizeThatFits)
        ToastView(title: "Your changes were saved and synced to all your devices", style: .prominent, onDismiss: {})
            .environment(\.dynamicTypeSize, .accessibility3)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Accessibility text size")
        ToastView(title: "Saved to your library", symbolName: "checkmark.circle.fill", background: .glass, style: .prominent, onDismiss: {})
            .padding(.vertical, 40)
            .background(LinearGradient(colors: [.orange, .purple], startPoint: .leading, endPoint: .trailing))
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Glass background")
    }
}

