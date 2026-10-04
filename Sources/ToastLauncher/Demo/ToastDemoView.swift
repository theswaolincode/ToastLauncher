//
//  ToastDemoView.swift
//  ToastLauncher
//
//  Created by Daniel Ayala on 4/10/26.
//

import SwiftUI

/// Example of how to present a `ToastView` using the `toastView` modifier.
/// Kept internal so it isn't part of the package's public API — open the preview in Xcode to try it.
struct ToastDemoView: View {
    @State private var isAutoToastPresented = false
    @State private var isProminentToastPresented = false

    var body: some View {
        VStack(spacing: 16) {
            Button("Show Auto-Dismiss Toast") {
                withAnimation { isAutoToastPresented = true }
            }
            Button("Show Prominent Toast") {
                withAnimation { isProminentToastPresented = true }
            }
        }
        .buttonStyle(.bordered)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .toastView(
            isPresented: $isAutoToastPresented,
            alignment: .top,
            animationStart: .move(edge: .top),
            animationEnd: .move(edge: .top).combined(with: .opacity)
        ) {
            ToastView(title: "Saved!", symbolName: "checkmark.circle.fill", style: .auto) {
                withAnimation { isAutoToastPresented = false }
            }
        }
        .toastView(
            isPresented: $isProminentToastPresented,
            alignment: .bottom,
            animationStart: .move(edge: .bottom),
            animationEnd: .opacity
        ) {
            ToastView(title: "Something needs your attention", symbolName: "exclamationmark.triangle.fill", buttonTitle: "Got It", style: .prominent) {
                withAnimation { isProminentToastPresented = false }
            }
        }
    }
}

#Preview {
    ToastDemoView()
}
