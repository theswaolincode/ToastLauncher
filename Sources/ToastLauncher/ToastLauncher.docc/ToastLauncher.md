# ``ToastLauncher``

Present toasts and other overlay views in SwiftUI with a single modifier.

## Overview

ToastLauncher shows lightweight, temporary messages on top of your content. Toasts
auto-dismiss after a configurable duration, can be swiped away, queue up instead of
overlapping, and use Liquid Glass on iOS 26 and later. They're built to be accessible:
VoiceOver announces them, text scales with Dynamic Type, and animations respect
Reduce Motion.

```swift
@State private var isSaved = false

var body: some View {
    Button("Save") { isSaved = true }
        .toast(isPresented: $isSaved) {
            ToastView(title: "Saved", symbolName: "checkmark.circle.fill",
                      background: .glass, style: .auto) {
                isSaved = false
            }
        }
}
```

Any SwiftUI view can be a toast. Use ``ToastView`` for a ready-made design, or build your
own content and give it a matching look with ``SwiftUI/View/toastBackground(_:cornerRadius:)``.

## Topics

### Essentials

- <doc:GettingStarted>
- ``SwiftUI/View/toast(isPresented:alignment:duration:dragToDismiss:haptic:transition:animation:onDismiss:content:)``
- ``ToastView``

### Showing Several Toasts

- ``ToastQueue``
- ``SwiftUI/View/toastQueue(_:alignment:dragToDismiss:haptic:transition:animation:)``

### Appearance

- ``SwiftUI/View/toastBackground(_:cornerRadius:)``
- ``ToastBackgroundStyle``

### Feedback and Accessibility

- ``SwiftUI/View/toastAnnouncement(_:)``
- ``ToastHaptic``

### Original API

- ``SwiftUI/View/toastView(isPresented:alignment:animationStart:animationEnd:onDismiss:content:)``
- ``ToastLauncher/ToastLauncher``
