//
//  Extension+View.swift
//  SwiftUI-Components
//
//  Created by Daniel Ayala on 15/10/22.
//

import SwiftUI

extension View {
    public func toastView<Content>(isPresented: Binding<Bool>, alignment: Alignment, animationStart: AnyTransition, animationEnd: AnyTransition, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
    
        self.overlay(
            isPresented.wrappedValue ? content().transition(.asymmetric(insertion: animationStart, removal: animationEnd)) : nil,
            alignment: alignment)
    }
}
