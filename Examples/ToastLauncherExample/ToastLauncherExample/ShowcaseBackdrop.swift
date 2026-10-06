//
//  ShowcaseBackdrop.swift
//  ToastLauncherExample
//
//  Created by Daniel Ayala on 06/10/2026.
//

import SwiftUI

/// A soft, slowly drifting mesh gradient — enough depth for Liquid Glass to refract,
/// without competing with the toasts.
///
/// It holds still when Reduce Motion is on, and falls back to a plain gradient before iOS 18.
struct ShowcaseBackdrop: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if #available(iOS 18.0, *) {
            TimelineView(.animation(paused: reduceMotion)) { context in
                mesh(at: reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate)
            }
        } else {
            LinearGradient(colors: [palette[1], palette[4], palette[8]],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    @available(iOS 18.0, *)
    private func mesh(at time: TimeInterval) -> some View {
        // Only the four inner edge points and the centre move, so the corners stay pinned
        // and the gradient always fills the screen.
        let t = Float(time)
        let drift: (Float, Float) -> Float = { speed, phase in 0.08 * sin(t * speed + phase) }
        let points: [SIMD2<Float>] = [
            [0, 0], [0.5 + drift(0.31, 0), 0], [1, 0],
            [0, 0.5 + drift(0.27, 1)], [0.5 + drift(0.23, 2), 0.5 + drift(0.29, 3)], [1, 0.5 + drift(0.33, 4)],
            [0, 1], [0.5 + drift(0.25, 5), 1], [1, 1]
        ]
        return MeshGradient(width: 3, height: 3, points: points, colors: palette)
    }

    /// Nine colors, row by row: cool blues and lavenders with a warm hint in one corner.
    private var palette: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.05, green: 0.07, blue: 0.16), Color(red: 0.10, green: 0.12, blue: 0.30), Color(red: 0.06, green: 0.16, blue: 0.32),
                Color(red: 0.09, green: 0.10, blue: 0.24), Color(red: 0.16, green: 0.14, blue: 0.36), Color(red: 0.07, green: 0.12, blue: 0.26),
                Color(red: 0.04, green: 0.05, blue: 0.12), Color(red: 0.12, green: 0.09, blue: 0.24), Color(red: 0.05, green: 0.08, blue: 0.18)
            ]
        }
        return [
            Color(red: 0.86, green: 0.91, blue: 1.00), Color(red: 0.93, green: 0.94, blue: 1.00), Color(red: 0.84, green: 0.88, blue: 1.00),
            Color(red: 0.90, green: 0.88, blue: 1.00), Color(red: 0.98, green: 0.98, blue: 1.00), Color(red: 0.87, green: 0.92, blue: 1.00),
            Color(red: 0.95, green: 0.93, blue: 0.98), Color(red: 0.89, green: 0.87, blue: 0.99), Color(red: 1.00, green: 0.93, blue: 0.91)
        ]
    }
}

#Preview {
    ShowcaseBackdrop()
        .ignoresSafeArea()
}
