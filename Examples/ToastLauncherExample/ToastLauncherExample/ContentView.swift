//
//  ContentView.swift
//  ToastLauncherExample
//
//  Created by Daniel Ayala on 04/10/2026.
//

import SwiftUI
import ToastLauncher

/// One screen that shows every ToastLauncher feature, laid out for a short screen recording.
struct ContentView: View {
    @StateObject private var queue = ToastQueue()
    @State private var backgroundStyle: ToastBackgroundStyle = .glass

    @State private var isSavedPresented = false
    @State private var isCopiedPresented = false
    @State private var isOfflinePresented = false
    @State private var isCenteredPresented = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                stylePicker
                demoSection("Single toasts") {
                    demoButton("Top · auto-dismiss + haptic", systemImage: "arrow.up.to.line") {
                        isSavedPresented = true
                    }
                    demoButton("Bottom · swipe down to dismiss", systemImage: "arrow.down.to.line") {
                        isCopiedPresented = true
                    }
                    demoButton("Stays until dismissed", systemImage: "pin.fill") {
                        isOfflinePresented = true
                    }
                    demoButton("Centered", systemImage: "circle.grid.cross.fill") {
                        isCenteredPresented = true
                    }
                }
                demoSection("Queue") {
                    demoButton("Queue 3 toasts", systemImage: "square.stack.3d.up.fill") {
                        enqueueUploads()
                    }
                }
                Text("Tip: swipe a toast toward its edge to dismiss it early.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        // A subtle backdrop keeps the focus on the toasts.
        .background(backdrop.ignoresSafeArea())
        // Top: the built-in ToastView, auto-dismissing with a success haptic.
        .toast(isPresented: $isSavedPresented, haptic: .success) {
            ToastView(title: "Saved", symbolName: "checkmark.circle.fill", background: backgroundStyle, style: .auto) {
                isSavedPresented = false
            }
        }
        // Bottom: custom content, swiped down to dismiss.
        .toast(isPresented: $isCopiedPresented, alignment: .bottom) {
            customToast("Copied to clipboard", systemImage: "doc.on.doc.fill")
        }
        // Stays until the person taps OK (or uses the VoiceOver escape gesture).
        .toast(isPresented: $isOfflinePresented, duration: nil, haptic: .warning) {
            ToastView(title: "You're offline. Changes will sync when you reconnect.",
                      symbolName: "wifi.slash", buttonTitle: "OK",
                      background: backgroundStyle, style: .prominent) {
                isOfflinePresented = false
            }
        }
        // Centered toasts scale in and can't be dragged.
        .toast(isPresented: $isCenteredPresented, alignment: .center, duration: 2) {
            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.largeTitle)
                    .accessibilityHidden(true)
                Text("Centered toasts scale in")
                    .font(.headline)
            }
            .padding(24)
            .toastBackground(backgroundStyle, cornerRadius: 24)
            .toastAnnouncement("Centered toasts scale in")
        }
        .toastQueue(queue, alignment: .bottom, haptic: .success)
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: 4) {
            Text("ToastLauncher")
                .font(.largeTitle.bold())
            Text("Accessible SwiftUI toasts")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top)
    }

    private var stylePicker: some View {
        demoSection("Background") {
            Picker("Background", selection: $backgroundStyle) {
                Text("Glass").tag(ToastBackgroundStyle.glass)
                Text("Material").tag(ToastBackgroundStyle.material)
                Text("Solid").tag(ToastBackgroundStyle.solid)
            }
            .pickerStyle(.segmented)
        }
    }

    /// A quiet, system-style backdrop: the grouped background with a soft blue wash at the top.
    /// System colors keep it right in both Light and Dark Mode.
    private var backdrop: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
            LinearGradient(colors: [Color.blue.opacity(0.18), Color.indigo.opacity(0.06), .clear],
                           startPoint: .top, endPoint: .bottom)
        }
    }

    // MARK: - Building blocks

    private func demoSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func demoButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }

    /// Custom toast content that matches the selected background and announces itself to VoiceOver.
    private func customToast(_ message: String, systemImage: String) -> some View {
        Label(message, systemImage: systemImage)
            .font(.headline)
            .padding()
            .toastBackground(backgroundStyle)
            .padding()
            .toastAnnouncement(message)
    }

    // MARK: - Actions

    private func enqueueUploads() {
        for index in 1...3 {
            queue.enqueue(duration: 1.5) {
                customToast("Photo \(index) of 3 uploaded", systemImage: "photo.fill")
            }
        }
    }
}

#Preview {
    ContentView()
}
