//
//  ContentView.swift
//  ToastLauncherExample
//
//  Created by Daniel Ayala on 04/10/2026.
//

import SwiftUI
import ToastLauncher

/// One screen that shows every ToastLauncher feature, laid out for a short screen recording.
///
/// iPhone gets a compact list; iPad (regular width) gets a showcase layout with a hero,
/// a live code snippet for the last toast, and large demo tiles.
struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var queue = ToastQueue()
    @State private var backgroundStyle: ToastBackgroundStyle = .glass

    @State private var isSavedPresented = false
    @State private var isCopiedPresented = false
    @State private var isOfflinePresented = false
    @State private var isCenteredPresented = false

    /// The demo whose code the snippet card shows.
    @State private var lastDemo: Demo = .top
    /// Bumped on every tap so the hero icon can bounce.
    @State private var launchCount = 0
    /// The iPad hero title: bigger than `.largeTitle`, but still scales with Dynamic Type.
    @ScaledMetric(relativeTo: .largeTitle) private var heroTitleSize: CGFloat = 52

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                showcaseLayout
            } else {
                compactLayout
            }
        }
        .background(backdrop.ignoresSafeArea())
        // Top: the built-in ToastView, auto-dismissing with a success haptic.
        .toast(isPresented: $isSavedPresented, haptic: .success) {
            ToastView(title: "Saved", symbolName: "checkmark.circle.fill", background: backgroundStyle, style: .auto) {
                isSavedPresented = false
            }
            // ToastView fills the available width; keep it toast-sized on iPad.
            .frame(maxWidth: 480)
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
            .frame(maxWidth: 480)
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

    // MARK: - Compact layout (iPhone)

    private var compactLayout: some View {
        ScrollView {
            VStack(spacing: 20) {
                compactHeader
                demoSection("Background") {
                    backgroundPicker
                }
                demoSection("Single toasts") {
                    demoButton("Top · auto-dismiss + haptic", systemImage: Demo.top.symbol) { run(.top) }
                    demoButton("Bottom · swipe down to dismiss", systemImage: Demo.bottom.symbol) { run(.bottom) }
                    demoButton("Stays until dismissed", systemImage: Demo.stays.symbol) { run(.stays) }
                    demoButton("Centered", systemImage: Demo.centered.symbol) { run(.centered) }
                }
                demoSection("Queue") {
                    demoButton("Queue 3 toasts", systemImage: Demo.queue.symbol) { run(.queue) }
                }
                tip
            }
            .padding()
        }
    }

    private var compactHeader: some View {
        VStack(spacing: 4) {
            Text("ToastLauncher")
                .font(.largeTitle.bold())
            Text("Accessible SwiftUI toasts")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top)
    }

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

    // MARK: - Showcase layout (iPad)

    private var showcaseLayout: some View {
        HStack(alignment: .center, spacing: 40) {
            VStack(alignment: .leading, spacing: 32) {
                hero
                CodeSnippetView(fileName: "ContentView.swift",
                                code: lastDemo.snippet(background: backgroundStyle.codeName))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 20) {
                backgroundPicker
                    .controlSize(.large)
                tileGrid
                tip
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 56)
        .padding(.vertical, 32)
        .frame(maxWidth: 1240, maxHeight: .infinity)
        .frame(maxWidth: .infinity)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(spacing: 20) {
                AppIconTile(launchCount: launchCount)
                VStack(alignment: .leading, spacing: 4) {
                    Text("ToastLauncher")
                        .font(.system(size: heroTitleSize, weight: .bold, design: .rounded))
                    Text("Beautiful, accessible toasts for SwiftUI.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            FeatureChips()
        }
    }

    private var tileGrid: some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                ForEach([Demo.top, .bottom, .centered, .stays]) { demo in
                    DemoTile(demo: demo, isSelected: demo == lastDemo) { run(demo) }
                }
            }
            DemoTile(demo: .queue, isSelected: lastDemo == .queue) { run(.queue) }
        }
    }

    // MARK: - Shared pieces

    private var backgroundPicker: some View {
        Picker("Background", selection: $backgroundStyle) {
            Text("Glass").tag(ToastBackgroundStyle.glass)
            Text("Material").tag(ToastBackgroundStyle.material)
            Text("Solid").tag(ToastBackgroundStyle.solid)
        }
        .pickerStyle(.segmented)
    }

    private var tip: some View {
        Text("Tip: swipe a toast toward its edge to dismiss it early.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder private var backdrop: some View {
        if horizontalSizeClass == .regular {
            ShowcaseBackdrop()
        } else {
            // A quiet, system-style backdrop: the grouped background with a soft blue wash at the top.
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                LinearGradient(colors: [Color.blue.opacity(0.18), Color.indigo.opacity(0.06), .clear],
                               startPoint: .top, endPoint: .bottom)
            }
        }
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

    private func run(_ demo: Demo) {
        withAnimation(.easeInOut(duration: 0.25)) {
            lastDemo = demo
        }
        launchCount += 1
        switch demo {
        case .top: isSavedPresented = true
        case .bottom: isCopiedPresented = true
        case .centered: isCenteredPresented = true
        case .stays: isOfflinePresented = true
        case .queue: enqueueUploads()
        }
    }

    private func enqueueUploads() {
        for index in 1...3 {
            queue.enqueue(duration: 1.5) {
                customToast("Photo \(index) of 3 uploaded", systemImage: "photo.fill")
            }
        }
    }
}

// MARK: - Demo catalogue

/// Every demo on the screen, with the copy and code shown for it on iPad.
enum Demo: Identifiable {
    case top, bottom, centered, stays, queue

    var id: Self { self }

    var title: String {
        switch self {
        case .top: "Top"
        case .bottom: "Bottom"
        case .centered: "Centered"
        case .stays: "Persistent"
        case .queue: "Queue 3 toasts"
        }
    }

    var subtitle: String {
        switch self {
        case .top: "Auto-dismiss + haptic"
        case .bottom: "Swipe down to dismiss"
        case .centered: "Scales in, can't be dragged"
        case .stays: "Stays until you tap OK"
        case .queue: "One after another, never overlapping"
        }
    }

    var symbol: String {
        switch self {
        case .top: "arrow.up.to.line"
        case .bottom: "arrow.down.to.line"
        case .centered: "circle.grid.cross.fill"
        case .stays: "pin.fill"
        case .queue: "square.stack.3d.up.fill"
        }
    }

    var tint: Color {
        switch self {
        case .top: .blue
        case .bottom: .teal
        case .centered: .indigo
        case .stays: .orange
        case .queue: .purple
        }
    }

    /// The code that produces this toast, with the chosen background filled in.
    func snippet(background: String) -> String {
        switch self {
        case .top:
            """
            .toast(isPresented: $saved, haptic: .success) {
                ToastView(title: "Saved",
                          symbolName: "checkmark.circle.fill",
                          background: \(background),
                          style: .auto) { saved = false }
            }
            """
        case .bottom:
            """
            .toast(isPresented: $copied, alignment: .bottom) {
                Label("Copied to clipboard", systemImage: "doc.on.doc.fill")
                    .padding()
                    .toastBackground(\(background))
            }
            """
        case .centered:
            """
            .toast(isPresented: $sparkle, alignment: .center, duration: 2) {
                SparkleCard()
                    .padding(24)
                    .toastBackground(\(background), cornerRadius: 24)
            }
            """
        case .stays:
            """
            // duration: nil keeps it up until the person acts
            .toast(isPresented: $offline, duration: nil, haptic: .warning) {
                ToastView(title: "You're offline…",
                          buttonTitle: "OK",
                          background: \(background),
                          style: .prominent) { offline = false }
            }
            """
        case .queue:
            """
            @StateObject var queue = ToastQueue()

            for index in 1...3 {
                queue.enqueue(duration: 1.5) {
                    UploadToast(index).toastBackground(\(background))
                }
            }
            """
        }
    }
}

private extension ToastBackgroundStyle {
    /// How this style is spelled in Swift, for the code snippet.
    var codeName: String {
        switch self {
        case .glass: ".glass"
        case .material: ".material"
        case .solid: ".solid"
        }
    }
}

// MARK: - Showcase components

/// A rounded "app icon" that bounces each time a toast launches.
private struct AppIconTile: View {
    let launchCount: Int

    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(LinearGradient(colors: [Color(red: 0.35, green: 0.55, blue: 1.0), Color(red: 0.42, green: 0.32, blue: 0.95)],
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 96, height: 96)
            .overlay(
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(.white)
                    .bounceEffect(trigger: launchCount)
            )
            .shadow(color: Color.indigo.opacity(0.35), radius: 18, y: 10)
            .accessibilityHidden(true)
    }
}

/// The feature list, as small material capsules.
private struct FeatureChips: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                chip("Liquid Glass", systemImage: "drop.fill")
                chip("VoiceOver", systemImage: "accessibility")
                chip("Dynamic Type", systemImage: "textformat.size")
            }
            HStack(spacing: 10) {
                chip("Reduce Motion", systemImage: "figure.walk.motion")
                chip("Swift 6", systemImage: "swift")
                chip("iOS 15+", systemImage: "iphone")
            }
        }
    }

    private func chip(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.thinMaterial, in: Capsule())
    }
}

/// A large, tappable card for one demo.
private struct DemoTile: View {
    let demo: Demo
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: demo.symbol)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(LinearGradient(colors: [demo.tint.opacity(0.75), demo.tint],
                                               startPoint: .top, endPoint: .bottom),
                                in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    Text(demo.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(demo.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(isSelected ? demo.tint.opacity(0.7) : Color.white.opacity(0.5),
                                  lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PressableButtonStyle())
    }
}

/// Shrinks slightly while pressed, like system cards.
private struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

private extension View {
    /// Bounces the contained SF Symbol whenever `trigger` changes (iOS 17+).
    @ViewBuilder func bounceEffect(trigger: Int) -> some View {
        if #available(iOS 17.0, *) {
            symbolEffect(.bounce, value: trigger)
        } else {
            self
        }
    }
}

#Preview("iPhone") {
    ContentView()
}

@available(iOS 17.0, *)
#Preview("iPad landscape", traits: .landscapeLeft) {
    ContentView()
        .environment(\.horizontalSizeClass, .regular)
}
