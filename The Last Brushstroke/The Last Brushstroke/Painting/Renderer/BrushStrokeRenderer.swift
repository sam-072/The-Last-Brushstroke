import SpriteKit

final class BrushStrokeRenderer {

    private let canvasRect: CGRect

    private var paintingStroke: SKShapeNode?

    init(canvasRect: CGRect) {
        self.canvasRect = canvasRect
    }

    func add(to parent: SKNode) {
        addSun(to: parent)
        addClouds(to: parent)

        let stroke = SKShapeNode(
            rectOf: CGSize(
                width: 4,
                height: 8
            ),
            cornerRadius: 4
        )

        stroke.fillColor = SKColor(
            red: 0.18,
            green: 0.32,
            blue: 0.20,
            alpha: 1
        )

        stroke.strokeColor = .clear
        stroke.zPosition = 5

        parent.addChild(stroke)

        paintingStroke = stroke
    }

    func updateStroke(progress: Double) {
        guard let paintingStroke else {
            return
        }

        let progress = min(max(progress, 0), 1)

        let startX = canvasRect.minX
            + canvasRect.width * 0.15

        let endX = canvasRect.minX
            + canvasRect.width * 0.85

        let currentX = startX
            + (endX - startX) * progress

        let width = max(
            4,
            currentX - startX
        )

        paintingStroke.path = CGPath(
            roundedRect: CGRect(
                x: startX,
                y: canvasRect.minY
                    + canvasRect.height * 0.72,
                width: width,
                height: 8
            ),
            cornerWidth: 4,
            cornerHeight: 4,
            transform: nil
        )
    }

    private func addSun(to parent: SKNode) {
        let sun = SKShapeNode(circleOfRadius: 32)

        sun.position = CGPoint(
            x: canvasRect.minX + canvasRect.width * 0.78,
            y: canvasRect.minY + canvasRect.height * 0.78
        )

        sun.fillColor = SKColor(
            red: 1.0,
            green: 0.72,
            blue: 0.20,
            alpha: 1
        )

        sun.strokeColor = .clear

        parent.addChild(sun)
    }

    private func addClouds(to parent: SKNode) {
        addCloud(
            at: CGPoint(
                x: canvasRect.minX + canvasRect.width * 0.25,
                y: canvasRect.minY + canvasRect.height * 0.78
            ),
            to: parent
        )

        addCloud(
            at: CGPoint(
                x: canvasRect.minX + canvasRect.width * 0.52,
                y: canvasRect.minY + canvasRect.height * 0.84
            ),
            to: parent
        )
    }

    private func addCloud(
        at position: CGPoint,
        to parent: SKNode
    ) {
        let cloud = SKNode()
        cloud.position = position

        let main = SKShapeNode(
            ellipseOf: CGSize(
                width: 70,
                height: 30
            )
        )

        main.fillColor = .white.withAlphaComponent(0.85)
        main.strokeColor = .clear

        cloud.addChild(main)

        let left = SKShapeNode(
            circleOfRadius: 18
        )

        left.position = CGPoint(
            x: -20,
            y: 8
        )

        left.fillColor = .white.withAlphaComponent(0.85)
        left.strokeColor = .clear

        cloud.addChild(left)

        let right = SKShapeNode(
            circleOfRadius: 15
        )

        right.position = CGPoint(
            x: 22,
            y: 6
        )

        right.fillColor = .white.withAlphaComponent(0.85)
        right.strokeColor = .clear

        cloud.addChild(right)

        parent.addChild(cloud)
    }
}
