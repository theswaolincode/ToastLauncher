//
//  ToastQueue.swift
//  ToastLauncher
//
//  Created by Daniel Ayala on 4/10/26.
//

import SwiftUI

/// Shows toasts one after another instead of overlapping them.
///
/// Own it with `@StateObject`, attach it with `toastQueue(_:)`, and call ``enqueue(duration:content:)``
/// from anywhere on the main actor:
///
/// ```swift
/// @StateObject private var toasts = ToastQueue()
///
/// var body: some View {
///     Button("Save") { toasts.enqueue { Text("Saved") } }
///         .toastQueue(toasts)
/// }
/// ```
// `ObservableObject` rather than `@Observable`: Observation requires iOS 17 and we support iOS 15.
@MainActor
public final class ToastQueue: ObservableObject {
    struct Item: Identifiable {
        let id = UUID()
        let duration: TimeInterval?
        // Type-erased so toasts with different content types can share one queue.
        let content: AnyView
    }

    /// The toast on screen, if any.
    @Published private(set) var current: Item?
    private(set) var pending: [Item] = []
    /// The pause before showing the next toast. Internal so tests can await it.
    private(set) var advanceTask: Task<Void, Never>?

    private let gap: TimeInterval
    private let sleep: ToastAutoDismiss.Sleep

    public convenience init() {
        // Roughly the length of the default removal animation, so toasts never overlap.
        self.init(gap: 0.35, sleep: ToastAutoDismiss.systemSleep)
    }

    init(gap: TimeInterval, sleep: @escaping ToastAutoDismiss.Sleep) {
        self.gap = gap
        self.sleep = sleep
    }

    /// Adds a toast. It's shown right away if nothing is on screen, otherwise after the ones before it.
    ///
    /// - Parameters:
    ///   - duration: Seconds before auto-dismissing, or `nil` to stay until dismissed. Defaults to 3.
    ///   - content: The toast's view.
    public func enqueue<Content: View>(duration: TimeInterval? = 3, @ViewBuilder content: () -> Content) {
        pending.append(Item(duration: duration, content: AnyView(content())))
        if current == nil && advanceTask == nil {
            showNext()
        }
    }

    /// Dismisses the toast on screen; the next one follows after a short pause.
    public func dismissCurrent() {
        guard current != nil else { return }
        current = nil
        scheduleNext()
    }

    /// Dismisses the toast on screen and discards everything waiting.
    public func removeAll() {
        pending.removeAll()
        advanceTask?.cancel()
        advanceTask = nil
        current = nil
    }

    private func showNext() {
        guard current == nil, !pending.isEmpty else { return }
        current = pending.removeFirst()
    }

    private func scheduleNext() {
        guard advanceTask == nil, !pending.isEmpty else { return }
        advanceTask = Task { [weak self, gap, sleep] in
            do {
                try await sleep(UInt64(gap * 1_000_000_000))
            } catch {
                return
            }
            guard let self, !Task.isCancelled else { return }
            self.advanceTask = nil
            self.showNext()
        }
    }
}
