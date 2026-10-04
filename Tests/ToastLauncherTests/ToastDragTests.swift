//
//  ToastDragTests.swift
//  ToastLauncherTests
//
//  Created by Daniel Ayala on 4/10/26.
//

import SwiftUI
import Testing
@testable import ToastLauncher

@Suite("Drag to dismiss")
struct ToastDragTests {
    /// A drag of 80pt toward each edge, paired with that edge.
    static let towardEdge: [(Edge, CGSize)] = [
        (.top, CGSize(width: 0, height: -80)),
        (.bottom, CGSize(width: 0, height: 80)),
        (.leading, CGSize(width: -80, height: 0)),
        (.trailing, CGSize(width: 80, height: 0)),
    ]

    @Test("Measures distance as positive toward the edge", arguments: towardEdge)
    func distanceTowardEdge(edge: Edge, translation: CGSize) {
        #expect(ToastDrag.distance(translation, toward: edge) == 80)
        #expect(ToastDrag.distance(CGSize(width: -translation.width, height: -translation.height), toward: edge) == -80)
    }

    @Test("Follows the finger toward the edge", arguments: towardEdge)
    func followsFingerTowardEdge(edge: Edge, translation: CGSize) {
        #expect(ToastDrag.offset(for: translation, toward: edge) == translation)
    }

    @Test("Resists dragging away from the edge, up to a limit", arguments: towardEdge)
    func resistsAwayFromEdge(edge: Edge, translation: CGSize) {
        let away = CGSize(width: -translation.width * 100, height: -translation.height * 100)

        let offset = ToastDrag.offset(for: away, toward: edge)
        let pulled = -ToastDrag.distance(offset, toward: edge)

        #expect(pulled > 0)
        #expect(pulled < ToastDrag.resistanceLimit)
    }

    @Test("Ignores movement across the drag axis")
    func ignoresCrossAxis() {
        #expect(ToastDrag.offset(for: CGSize(width: 40, height: -80), toward: .top) == CGSize(width: 0, height: -80))
        #expect(ToastDrag.offset(for: CGSize(width: 80, height: 40), toward: .trailing) == CGSize(width: 80, height: 0))
    }

    @Test("Centered toasts don't move or dismiss")
    func centeredToast() {
        let drag = CGSize(width: 300, height: -300)

        #expect(ToastDrag.offset(for: drag, toward: nil) == .zero)
        #expect(!ToastDrag.shouldDismiss(predictedEndTranslation: drag, toward: nil))
    }

    @Test("Dismisses only when the projected drag reaches the threshold",
          arguments: [
            (ToastDrag.dismissThreshold, true),
            (ToastDrag.dismissThreshold - 1, false),
            (200, true),
            (-200, false),
          ] as [(CGFloat, Bool)])
    func dismissThreshold(upwardDistance: CGFloat, expected: Bool) {
        let predicted = CGSize(width: 0, height: -upwardDistance)

        #expect(ToastDrag.shouldDismiss(predictedEndTranslation: predicted, toward: .top) == expected)
    }
}
