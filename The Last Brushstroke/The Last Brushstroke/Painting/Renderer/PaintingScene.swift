import SpriteKit

final class PaintingScene: SKScene {
    private var paintingState = PaintingState(
        status: .idle,
        accumulatedDuration: 0,
        progress: 0
    )

    private var canvasNode: CanvasNode?
    private var painterNode: PainterNode?
    private var painterAnimationController: PainterAnimationController?

    private(set) var renderedStage: PaintingVisualStage = .blank

    override init(size: CGSize) {
        super.init(size: size)

        scaleMode = .resizeFill
        backgroundColor = SKColor(
            red: 0.08,
            green: 0.10,
            blue: 0.13,
            alpha: 1
        )
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        scaleMode = .resizeFill
        backgroundColor = SKColor(
            red: 0.08,
            green: 0.10,
            blue: 0.13,
            alpha: 1
        )
    }

    override func didMove(to view: SKView) {
        rebuildScene()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard size.width > 0, size.height > 0 else {
            return
        }

        rebuildScene()
    }

    func render(state: PaintingState) {
        paintingState = state
        renderedStage = PaintingVisualStage(progress: state.progress)

        if canvasNode == nil {
            rebuildScene()
        } else {
            applyPaintingState()
        }
    }

    private func rebuildScene() {
        removeAllChildren()

        let canvasRect = CGRect(
            x: size.width * 0.08,
            y: size.height * 0.12,
            width: size.width * 0.84,
            height: size.height * 0.76
        )

        let canvas = CanvasNode(canvasRect: canvasRect)
        let painter = PainterNode()

        addChild(canvas)
        addChild(painter)

        canvasNode = canvas
        painterNode = painter

        painterAnimationController = PainterAnimationController(
            painter: painter
        )

        applyPaintingState()
    }

    private func applyPaintingState() {
        canvasNode?.render(progress: paintingState.progress)

        updatePainterPosition()

        painterAnimationController?.update(
            for: paintingState.status
        )
    }
    private func updatePainterPosition() {
        guard let painter = painterNode else {
            return
        }

        guard let canvasNode else {
            return
        }

        let canvasRect = canvasNode.canvasRect

        let progress = CGFloat(
            min(max(paintingState.progress, 0), 1)
        )

        let startX = canvasRect.minX
            + canvasRect.width * 0.15

        let endX = canvasRect.minX
            + canvasRect.width * 0.85

        let x = startX
            + (endX - startX) * progress

        let y = canvasRect.minY
            + canvasRect.height * 0.72
            - 42

        painter.position = CGPoint(
            x: x,
            y: y
        )
    }
}
