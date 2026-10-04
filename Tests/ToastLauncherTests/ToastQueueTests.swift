//
//  ToastQueueTests.swift
//  ToastLauncherTests
//
//  Created by Daniel Ayala on 4/10/26.
//

import SwiftUI
import Testing
@testable import ToastLauncher

// `ToastQueue` is main-actor isolated, so the whole suite runs on the main actor.
@MainActor
@Suite("Toast queue")
struct ToastQueueTests {
    /// A queue whose gap between toasts passes instantly.
    private func makeQueue() -> ToastQueue {
        ToastQueue(gap: 0.35, sleep: { _ in })
    }

    @Test("Shows the first toast immediately")
    func showsFirstImmediately() {
        let queue = makeQueue()

        queue.enqueue(duration: 1) { Text("A") }

        #expect(queue.current?.duration == 1)
        #expect(queue.pending.isEmpty)
    }

    @Test("Shows toasts one at a time, in order")
    func firstInFirstOut() async {
        let queue = makeQueue()
        // Durations double as identifiers for which toast is on screen.
        queue.enqueue(duration: 1) { Text("A") }
        queue.enqueue(duration: 2) { Text("B") }
        queue.enqueue(duration: 3) { Text("C") }
        #expect(queue.current?.duration == 1)
        #expect(queue.pending.count == 2)

        queue.dismissCurrent()
        await queue.advanceTask?.value
        #expect(queue.current?.duration == 2)

        queue.dismissCurrent()
        await queue.advanceTask?.value
        #expect(queue.current?.duration == 3)
        #expect(queue.pending.isEmpty)
    }

    @Test("Shows nothing during the gap between toasts")
    func gapBetweenToasts() async {
        let recorder = SleepRecorder()
        let queue = ToastQueue(gap: 0.35, sleep: { await recorder.record($0) })
        queue.enqueue { Text("A") }
        queue.enqueue { Text("B") }

        queue.dismissCurrent()

        // Going through "nothing on screen" lets the removal animation finish
        // and gives the next toast a fresh auto-dismiss timer.
        #expect(queue.current == nil)
        #expect(queue.advanceTask != nil)
        await queue.advanceTask?.value
        #expect(await recorder.calls == [350_000_000])
    }

    @Test("A toast enqueued during the gap waits its turn")
    func enqueueDuringGap() async {
        let queue = makeQueue()
        queue.enqueue(duration: 1) { Text("A") }
        queue.enqueue(duration: 2) { Text("B") }
        queue.dismissCurrent()

        queue.enqueue(duration: 3) { Text("C") }

        #expect(queue.current == nil)
        await queue.advanceTask?.value
        #expect(queue.current?.duration == 2)
        #expect(queue.pending.first?.duration == 3)
    }

    @Test("Dismissing the last toast doesn't schedule anything")
    func dismissLast() {
        let queue = makeQueue()
        queue.enqueue { Text("A") }

        queue.dismissCurrent()

        #expect(queue.current == nil)
        #expect(queue.advanceTask == nil)
    }

    @Test("Dismissing when nothing is on screen is a no-op")
    func dismissWhenEmpty() async {
        let queue = makeQueue()
        queue.enqueue(duration: 1) { Text("A") }
        queue.enqueue(duration: 2) { Text("B") }
        queue.enqueue(duration: 3) { Text("C") }
        queue.dismissCurrent()

        // A second dismiss during the gap must not skip "B".
        queue.dismissCurrent()
        await queue.advanceTask?.value

        #expect(queue.current?.duration == 2)
        #expect(queue.pending.count == 1)
    }

    @Test("removeAll clears everything and cancels the pending advance")
    func removeAll() async {
        // A sleep that only ends when cancelled, so the advance is still pending.
        let queue = ToastQueue(gap: 0.35, sleep: { _ in try await Task.sleep(nanoseconds: 60_000_000_000) })
        queue.enqueue { Text("A") }
        queue.enqueue { Text("B") }
        queue.dismissCurrent()
        let advance = queue.advanceTask

        queue.removeAll()
        await advance?.value

        #expect(queue.current == nil)
        #expect(queue.pending.isEmpty)
        #expect(queue.advanceTask == nil)
    }
}
