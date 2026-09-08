//
//  BrushStrokeRenderer.swift
//  The Last Brushstroke
//

import SpriteKit

final class BrushStrokeRenderer {
    private let canvasRect: CGRect

    init(canvasRect: CGRect) {
        self.canvasRect = canvasRect
    }

    func add(to parent: SKNode) {
        let sun = SKShapeNode(circleOfRadius: min(canvasRect.width, canvasRect.height) * 0.08)
        sun.position = CGPoint(x: canvasRect.midX + canvasRect.width * 0.24, y: canvasRect.midY + canvasRect.height * 0.22)
        sun.fillColor = SKColor(red: 1, green: 0.82, blue: 0.36, alpha: 1)
        sun.strokeColor = .clear
        parent.addChild(sun)

        for position in [
            CGPoint(x: canvasRect.minX + canvasRect.width * 0.22, y: canvasRect.midY + canvasRect.height * 0.23),
            CGPoint(x: canvasRect.minX + canvasRect.width * 0.66, y: canvasRect.midY + canvasRect.height * 0.30)
        ] {
            addCloud(at: position, to: parent)
        }
    }

    private func addCloud(at position: CGPoint, to parent: SKNode) {
        let cloud = SKNode()
        cloud.position = position
        for offset in [CGPoint(x: -22, y: 0), CGPoint(x: 0, y: 8), CGPoint(x: 24, y: 0)] {
            let puff = SKShapeNode(circleOfRadius: 18)
            puff.position = offset
            puff.fillColor = SKColor.white.withAlphaComponent(0.72)
            puff.strokeColor = .clear
            cloud.addChild(puff)
        }
        parent.addChild(cloud)
    }
}
