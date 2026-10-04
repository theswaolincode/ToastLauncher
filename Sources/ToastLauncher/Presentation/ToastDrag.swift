//
//  ToastDrag.swift
//  ToastLauncher
//
//  Created by Daniel Ayala on 4/10/26.
//

import SwiftUI

/// Drag-to-dismiss math, kept free of view state so it can be unit tested.
///
/// Toasts are dismissed by swiping toward the edge they're anchored to.
/// Centered toasts (no edge) can't be dragged.
enum ToastDrag {
    /// How far (in points) the drag must be projected to travel toward the edge to dismiss.
    static let dismissThreshold: CGFloat = 50
    /// Maximum distance a toast can be pulled away from its edge before it stops following.
    static let resistanceLimit: CGFloat = 24

    /// Signed distance travelled toward `edge`: positive means toward it.
    static func distance(_ translation: CGSize, toward edge: Edge) -> CGFloat {
        switch edge {
        case .top: return -translation.height
        case .bottom: return translation.height
        case .leading: return -translation.width
        case .trailing: return translation.width
        }
    }

    /// The visual offset for a drag: follows the finger toward the edge, rubber-bands the
    /// other way, and ignores movement on the cross axis.
    static func offset(for translation: CGSize, toward edge: Edge?) -> CGSize {
        guard let edge else { return .zero }
        let travelled = distance(translation, toward: edge)
        let constrained = travelled >= 0 ? travelled : -rubberBand(-travelled)
        switch edge {
        case .top: return CGSize(width: 0, height: -constrained)
        case .bottom: return CGSize(width: 0, height: constrained)
        case .leading: return CGSize(width: -constrained, height: 0)
        case .trailing: return CGSize(width: constrained, height: 0)
        }
    }

    /// Whether a finished drag should dismiss the toast.
    ///
    /// Uses the *predicted* end translation, which already includes the finger's momentum:
    /// a slow drag past the threshold dismisses, a quick flick toward the edge dismisses,
    /// and dragging out then flicking back springs back.
    static func shouldDismiss(predictedEndTranslation: CGSize, toward edge: Edge?) -> Bool {
        guard let edge else { return false }
        return distance(predictedEndTranslation, toward: edge) >= dismissThreshold
    }

    /// Approaches `resistanceLimit` asymptotically, so pulling harder moves it less and less.
    private static func rubberBand(_ distance: CGFloat) -> CGFloat {
        resistanceLimit * (1 - 1 / (distance / resistanceLimit + 1))
    }
}
