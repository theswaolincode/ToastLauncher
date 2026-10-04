# Getting Started with ToastLauncher

Show your first toast, then tailor how long it stays, where it appears, and how it looks.

## Overview

A toast is controlled by a Boolean binding, just like a sheet. Set it to `true` to show
the toast; ToastLauncher sets it back to `false` when the toast dismisses itself.

### Show a toast

Attach ``SwiftUI/View/toast(isPresented:alignment:duration:dragToDismiss:haptic:transition:animation:onDismiss:content:)``
to any view and provide the toast's content:

```swift
struct ContentView: View {
    @State private var isSaved = false

    var body: some View {
        Button("Save") { isSaved = true }
            .toast(isPresented: $isSaved) {
                Label("Saved", systemImage: "checkmark.circle.fill")
                    .padding()
                    .toastBackground(.glass)
            }
    }
}
```

By default the toast slides in from the top, stays for 3 seconds, and can be swiped up
to dismiss it early. You don't need to wrap the change in `withAnimation`.

### Control how long it stays

Pass a `duration` in seconds, or `nil` to keep the toast on screen until it's dismissed:

```swift
.toast(isPresented: $isOffline, duration: nil) {
    ToastView(title: "You're offline", symbolName: "wifi.slash",
              buttonTitle: "OK", style: .prominent) {
        isOffline = false
    }
}
```

The timer pauses while someone drags the toast, and restarts if it springs back.
While VoiceOver is running, short durations are extended to at least 10 seconds so
there's time to reach the toast.

### Choose where it appears

The `alignment` decides both the position and the swipe direction: toasts aligned to the
top are swiped up, toasts aligned to the bottom are swiped down, and leading or trailing
toasts are swiped sideways.

```swift
.toast(isPresented: $isCopied, alignment: .bottom, haptic: .success) {
    Text("Copied to clipboard")
        .padding()
        .toastBackground(.glass)
}
```

Centered toasts scale in and can't be dragged. Set `dragToDismiss` to `false` to turn
swiping off entirely.

### Show several toasts in turn

When toasts can be triggered in quick succession, use a ``ToastQueue`` so they appear one
after another instead of overlapping:

```swift
@StateObject private var toasts = ToastQueue()

var body: some View {
    List(items) { item in
        Button(item.name) {
            toasts.enqueue { Text("\(item.name) added").padding().toastBackground() }
        }
    }
    .toastQueue(toasts, alignment: .bottom)
}
```

### Style your toasts

``ToastBackgroundStyle/glass`` uses Liquid Glass on iOS 26 and later and a translucent
material on earlier versions. Use ``ToastBackgroundStyle/material`` or
``ToastBackgroundStyle/solid`` for other looks. The modifier works on any view, so custom
content can match ``ToastView``:

```swift
HStack {
    Image(systemName: "arrow.down.circle.fill")
    Text("Download complete")
}
.padding()
.toastBackground(.glass, cornerRadius: 20)
```

### Make custom toasts accessible

``ToastView`` announces its title to VoiceOver automatically. For custom content, add
``SwiftUI/View/toastAnnouncement(_:)`` with a short message:

```swift
.toast(isPresented: $isSaved) {
    SavedBadge()
        .toastAnnouncement("Saved")
}
```

Toasts are grouped as a single accessibility container, and VoiceOver users can dismiss
them with the escape gesture (a two-finger scrub). When Reduce Motion is on, toasts fade
instead of sliding.

### Migrate from the original API

The original ``SwiftUI/View/toastView(isPresented:alignment:animationStart:animationEnd:onDismiss:content:)``
modifier still works exactly as before: it never auto-dismisses and animates with your own
`withAnimation`. Move to `toast(isPresented:...)` to get auto-dismiss, drag-to-dismiss,
haptics, and built-in animations.
