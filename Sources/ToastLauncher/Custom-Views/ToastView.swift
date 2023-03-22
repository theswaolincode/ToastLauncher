//
//  ToastView.swift
//  SwiftUI-Components
//
//  Created by Daniel Ayala on 16/10/22.
//

import SwiftUI

public struct ToastView: View {
    var title: String
    var symbolName: String
    var buttonTitle: String
    var style: ToastViewStyle
    var onDismiss:()-> Void
    
   public init(title: String? = nil, symbolName: String? = nil, buttonTitle: String? = nil, style: ToastViewStyle, onDismiss: @escaping () -> Void) {
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
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding()
    }
    
    private func autoDismiss() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        guard style == .auto else { return }
        onDismiss()
    }
    
    @ViewBuilder func buildActionButton() -> some View {
        if style == .prominent {
            Button(buttonTitle) { onDismiss() }
                .buttonStyle(.borderedProminent)
        }
    }
    
   public enum ToastViewStyle {
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

