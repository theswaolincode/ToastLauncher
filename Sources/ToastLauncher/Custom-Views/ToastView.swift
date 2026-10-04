//
//  ToastView.swift
//  SwiftUI-Components
//
//  Created by Daniel Ayala on 16/10/22.
//

import SwiftUI

@MainActor
public struct ToastView: View {
    var title: String
    var symbolName: String
    var buttonTitle: String
    var style: ToastViewStyle
    var onDismiss: @MainActor () -> Void
    
   public init(title: String? = nil, symbolName: String? = nil, buttonTitle: String? = nil, style: ToastViewStyle, onDismiss: @escaping @MainActor () -> Void) {
        self.title = title ?? "Hello, world!!"
        self.symbolName = symbolName ?? "globe"
        self.buttonTitle = buttonTitle ?? "Dismiss Me"
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
        // Adapts to light/dark mode: white in light, elevated gray in dark.
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding()
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
    
   public enum ToastViewStyle: Sendable {
        case auto
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
    }
}

