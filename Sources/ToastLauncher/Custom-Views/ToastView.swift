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

    public var body: some View {
        VStack {
            Image(systemName: symbolName)
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(title)
                .font(.body)
            buildActionButton()
        }
        
        .task {
            await autoDismiss()
        }
        .padding()
        .frame(maxWidth: .infinity)
        // Adapts to light/dark mode: white in light, elevated gray in dark.
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding()
    }
    
    private func autoDismiss() async {
        guard style == .auto else { return }
        do {
            try await Task.sleep(nanoseconds: 2_000_000_000)
        } catch {
            // `.task` cancels us when the view disappears (e.g. dismissed early).
            // Calling `onDismiss` here would fire a second, stale dismissal.
            return
        }
        onDismiss()
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
    }
}

