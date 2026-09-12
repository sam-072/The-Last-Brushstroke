import SpriteKit

final class PainterAnimationController {

    private let painter: PainterNode
    private let brushAnimation: BrushAnimation

    private(set) var isAnimating = false

    init(
        painter: PainterNode,
        brushAnimation: BrushAnimation = BrushAnimation()
    ) {
        self.painter = painter
        self.brushAnimation = brushAnimation
    }

    func update(for status: PaintingStatus) {
        switch status {

        case .painting:
            startPaintingAnimation()

        case .idle:
            stopAnimating(hidePainter: true)

        case .paused, .completed:
            stopAnimating(hidePainter: false)
        }
    }

    private func startPaintingAnimation() {
        painter.isHidden = false

        guard !isAnimating else {
            return
        }

        let bodyAction = SKAction.repeatForever(
            .sequence([
                .moveBy(
                    x: 3,
                    y: 0,
                    duration: 0.3
                ),
                .moveBy(
                    x: -3,
                    y: 0,
                    duration: 0.3
                )
            ])
        )

        painter.run(
            bodyAction,
            withKey: "painter.sway"
        )

        painter.armNode.run(
            brushAnimation.workingAction(),
            withKey: "painter.brush"
        )

        isAnimating = true
    }

    private func stopAnimating(hidePainter: Bool) {
        painter.removeAction(
            forKey: "painter.sway"
        )

        painter.armNode.removeAction(
            forKey: "painter.brush"
        )

        painter.resetPose()

        painter.isHidden = hidePainter

        isAnimating = false
    }
}
