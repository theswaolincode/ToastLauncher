//
//  ToastAutoDismissTests.swift
//  ToastLauncherTests
//
//  Created by Daniel Ayala on 4/10/26.
//

import Foundation
import Testing
@testable import ToastLauncher

/// Records the durations passed to an injected sleep, so tests never wait in real time.
actor SleepRecorder {
    private(set) var calls: [UInt64] = []

    func record(_ nanoseconds: UInt64) {
        calls.append(nanoseconds)
    }
}

@Suite("Auto-dismiss timer")
struct ToastAutoDismissTests {
    @Test("Dismisses once the full duration has elapsed")
    func dismissesAfterDuration() async {
        let recorder = SleepRecorder()

        let shouldDismiss = await ToastAutoDismiss.wait(for: 3) { await recorder.record($0) }

        #expect(shouldDismiss)
        #expect(await recorder.calls == [3_000_000_000])
    }

    @Test("Never starts a timer without a finite positive duration",
          arguments: [nil, 0, -1, .infinity, .nan] as [TimeInterval?])
    func ignoresInvalidDurations(duration: TimeInterval?) async {
        let recorder = SleepRecorder()

        let shouldDismiss = await ToastAutoDismiss.wait(for: duration) { await recorder.record($0) }

        #expect(!shouldDismiss)
        #expect(await recorder.calls.isEmpty)
    }

    @Test("Doesn't dismiss when the sleep is interrupted")
    func sleepThrows() async {
        let shouldDismiss = await ToastAutoDismiss.wait(for: 3) { _ in throw CancellationError() }

        #expect(!shouldDismiss)
    }

    @Test("Doesn't dismiss when the waiting task is cancelled early")
    func taskCancelled() async {
        // Uses the real sleep: cancellation must wake it up long before the 60 seconds pass.
        let task = Task { await ToastAutoDismiss.wait(for: 60) }
        task.cancel()

        #expect(await task.value == false)
    }

    @Test("Extends short durations only while VoiceOver is running",
          arguments: [
            (3, false, 3),
            (3, true, ToastAutoDismiss.voiceOverMinimumDuration),
            (15, true, 15),
            (nil, true, nil),
            (nil, false, nil),
          ] as [(TimeInterval?, Bool, TimeInterval?)])
    func effectiveDuration(duration: TimeInterval?, voiceOverEnabled: Bool, expected: TimeInterval?) {
        #expect(ToastAutoDismiss.effectiveDuration(duration, voiceOverEnabled: voiceOverEnabled) == expected)
    }
}
