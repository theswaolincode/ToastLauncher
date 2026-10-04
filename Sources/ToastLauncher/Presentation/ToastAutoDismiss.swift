//
//  ToastAutoDismiss.swift
//  ToastLauncher
//
//  Created by Daniel Ayala on 4/10/26.
//

import Foundation

/// Waits out a toast's auto-dismiss duration.
///
/// Kept separate from the view so the timing rules can be unit tested
/// with an injected `sleep` instead of waiting in real time.
enum ToastAutoDismiss {
    typealias Sleep = @Sendable (_ nanoseconds: UInt64) async throws -> Void

    static let systemSleep: Sleep = { try await Task.sleep(nanoseconds: $0) }

    /// Suspends for `duration` seconds.
    ///
    /// - Returns: `true` if the full duration elapsed and the toast should be dismissed;
    ///   `false` if there's no finite positive duration or the wait was cancelled.
    static func wait(for duration: TimeInterval?, sleep: Sleep = systemSleep) async -> Bool {
        guard let duration, duration.isFinite, duration > 0 else { return false }
        do {
            try await sleep(UInt64(duration * 1_000_000_000))
        } catch {
            return false
        }
        // A cancellation can land after the sleep finished but before this task resumed.
        return !Task.isCancelled
    }
}
