//
//  DismissingKeyboard.swift
//  Khawi
//
//  Created by Karim Amsha on 22.10.2023.
//

import SwiftUI

enum All {
    static let gestures = all(of: Gestures.self)

    private static func all<CI>(of _: CI.Type) -> CI.AllCases where CI: CaseIterable {
        return CI.allCases
    }
}

enum Gestures: Hashable, CaseIterable {
    case tap, longPress, drag, magnification, rotation
}

protocol ValueGesture: Gesture where Value: Equatable {
    func onChanged(_ action: @escaping (Value) -> Void) -> _ChangedGesture<Self>
}

extension LongPressGesture: ValueGesture {}
extension DragGesture: ValueGesture {}
extension MagnificationGesture: ValueGesture {}
extension RotationGesture: ValueGesture {}

extension Gestures {
    @discardableResult
    func apply<V>(to view: V, perform voidAction: @escaping () -> Void) -> AnyView where V: View {

        func highPrio<G>(gesture: G) -> AnyView where G: ValueGesture {
            AnyView(view.highPriorityGesture(
                gesture.onChanged { _ in
                    voidAction()
                }
            ))
        }

        switch self {
        case .tap:
            return AnyView(view.gesture(TapGesture().onEnded(voidAction)))
        case .longPress:
            return highPrio(gesture: LongPressGesture())
        case .drag:
            return highPrio(gesture: DragGesture())
        case .magnification:
            return highPrio(gesture: MagnificationGesture())
        case .rotation:
            return highPrio(gesture: RotationGesture())
        }
    }
}

struct DismissingKeyboard: ViewModifier {
    var gestures: [Gestures] = Gestures.allCases

    dynamic func body(content: Content) -> some View {
        let action = {
            let forcing = true
            let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first
            keyWindow?.endEditing(forcing)
        }

        return gestures.reduce(AnyView(content)) { $1.apply(to: $0, perform: action) }
    }
}

extension View {
    dynamic func dismissKeyboard(on gestures: [Gestures] = Gestures.allCases) -> some View {
        return ModifiedContent(content: self, modifier: DismissingKeyboard(gestures: gestures))
    }
}
