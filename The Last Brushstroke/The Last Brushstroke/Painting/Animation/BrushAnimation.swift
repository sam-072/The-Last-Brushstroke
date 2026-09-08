//
//  BrushAnimation.swift
//  The Last Brushstroke
//

import SpriteKit

struct BrushAnimation {
    func workingAction() -> SKAction {
        SKAction.repeatForever(.sequence([
            .rotate(toAngle: -0.24, duration: 0.22),
            .rotate(toAngle: 0.10, duration: 0.22)
        ]))
    }
}
