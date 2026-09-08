//
//  PainterAnimationController.swift
//  The Last Brushstroke
//

import SpriteKit

final class PainterAnimationController {
    private let painter: PainterNode
    private let brushAnimation: BrushAnimation

    private(set) var isAnimating = false

    init(painter: PainterNode, brushAnimation: BrushAnimation = BrushAnimation()) {
        self.painter = painter
        self.brushAnimation = brushAnimation
    }

    func update(for status: PaintingStatus) {
        switch status {
        case .painting:
            painter.isHidden = false
            guard !isAnimating else { return }
            painter.run(.repeatForever(.sequence([.moveBy(x: 4, y: 0, duration: 0.35), .moveBy(x: -4, y: 0, duration: 0.35)])), withKey: "painter.sway")
            painter.armNode.run(brushAnimation.workingAction(), withKey: "painter.brush")
            isAnimating = true
        case .idle:
            stopAnimating(hidePainter: true)
        case .paused, .completed:
            stopAnimating(hidePainter: false)
        }
    }

    private func stopAnimating(hidePainter: Bool) {
        painter.removeAction(forKey: "painter.sway")
        painter.armNode.removeAction(forKey: "painter.brush")
        painter.resetPose()
        painter.isHidden = hidePainter
        isAnimating = false
    }
}
