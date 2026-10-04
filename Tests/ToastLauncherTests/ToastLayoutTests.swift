//
//  ToastLayoutTests.swift
//  ToastLauncherTests
//
//  Created by Daniel Ayala on 4/10/26.
//

import SwiftUI
import Testing
@testable import ToastLauncher

@Suite("Layout")
struct ToastLayoutTests {
    @Test("Derives the anchored edge from the alignment; vertical alignment wins in corners",
          arguments: [
            (.top, .top), (.topLeading, .top), (.topTrailing, .top),
            (.bottom, .bottom), (.bottomLeading, .bottom), (.bottomTrailing, .bottom),
            (.leading, .leading), (.trailing, .trailing),
            (.center, nil),
          ] as [(Alignment, Edge?)])
    func edgeForAlignment(alignment: Alignment, expected: Edge?) {
        #expect(ToastLayout.edge(for: alignment) == expected)
    }
}
