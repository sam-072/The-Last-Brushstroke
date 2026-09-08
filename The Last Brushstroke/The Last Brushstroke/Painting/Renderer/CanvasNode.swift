//
//  CanvasNode.swift
//  The Last Brushstroke
//

import SpriteKit

final class CanvasNode: SKNode {
    private let canvasRect: CGRect
    private let skyNode = SKNode()
    private let mountainNode = SKNode()
    private let groundNode = SKNode()
    private let treeNode = SKNode()
    private let detailNode = SKNode()

    init(canvasRect: CGRect) {
        self.canvasRect = canvasRect
        super.init()
        addFrame()
        addLayers()
        render(progress: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func render(progress: Double) {
        let progress = min(max(progress, 0), 1)
        skyNode.alpha = reveal(progress, from: 0, to: 0.2)
        mountainNode.alpha = reveal(progress, from: 0.2, to: 0.4)
        groundNode.alpha = reveal(progress, from: 0.4, to: 0.6)
        treeNode.alpha = reveal(progress, from: 0.6, to: 0.8)
        detailNode.alpha = reveal(progress, from: 0.8, to: 1)
    }

    private func addFrame() {
        let shadow = SKShapeNode(rect: canvasRect.offsetBy(dx: 10, dy: -12), cornerRadius: 6)
        shadow.fillColor = SKColor.black.withAlphaComponent(0.35)
        shadow.strokeColor = .clear
        addChild(shadow)

        let canvas = SKShapeNode(rect: canvasRect, cornerRadius: 6)
        canvas.fillColor = SKColor(red: 0.96, green: 0.90, blue: 0.77, alpha: 1)
        canvas.strokeColor = SKColor(red: 0.42, green: 0.26, blue: 0.14, alpha: 1)
        canvas.lineWidth = 10
        canvas.zPosition = 1
        addChild(canvas)
    }

    private func addLayers() {
        let landscape = SKCropNode()
        landscape.zPosition = 2
        let mask = SKShapeNode(rect: canvasRect.insetBy(dx: 5, dy: 5), cornerRadius: 2)
        mask.fillColor = .white
        mask.strokeColor = .clear
        landscape.maskNode = mask

        addSky()
        addMountains()
        addGround()
        addTrees()
        BrushStrokeRenderer(canvasRect: canvasRect).add(to: detailNode)
        [skyNode, mountainNode, groundNode, treeNode, detailNode].forEach(landscape.addChild)
        addChild(landscape)
    }

    private func addSky() {
        let sky = SKShapeNode(rect: canvasRect)
        sky.fillColor = SKColor(red: 0.41, green: 0.68, blue: 0.84, alpha: 1)
        sky.strokeColor = .clear
        skyNode.addChild(sky)
    }

    private func addMountains() {
        let horizon = canvasRect.minY + canvasRect.height * 0.45
        mountainNode.addChild(polygon([
            CGPoint(x: canvasRect.minX - 20, y: horizon),
            CGPoint(x: canvasRect.minX + canvasRect.width * 0.24, y: canvasRect.maxY - canvasRect.height * 0.15),
            CGPoint(x: canvasRect.minX + canvasRect.width * 0.49, y: horizon)
        ], color: SKColor(red: 0.25, green: 0.38, blue: 0.44, alpha: 1)))
        mountainNode.addChild(polygon([
            CGPoint(x: canvasRect.minX + canvasRect.width * 0.28, y: horizon),
            CGPoint(x: canvasRect.minX + canvasRect.width * 0.59, y: canvasRect.maxY - canvasRect.height * 0.09),
            CGPoint(x: canvasRect.maxX + 20, y: horizon)
        ], color: SKColor(red: 0.18, green: 0.30, blue: 0.37, alpha: 1)))
    }

    private func addGround() {
        let horizon = canvasRect.minY + canvasRect.height * 0.45
        groundNode.addChild(polygon([
            CGPoint(x: canvasRect.minX, y: canvasRect.minY),
            CGPoint(x: canvasRect.maxX, y: canvasRect.minY),
            CGPoint(x: canvasRect.maxX, y: horizon),
            CGPoint(x: canvasRect.minX, y: horizon)
        ], color: SKColor(red: 0.22, green: 0.39, blue: 0.24, alpha: 1)))
    }

    private func addTrees() {
        addTree(at: CGPoint(x: canvasRect.minX + canvasRect.width * 0.15, y: canvasRect.minY + canvasRect.height * 0.12), scale: 1)
        addTree(at: CGPoint(x: canvasRect.minX + canvasRect.width * 0.82, y: canvasRect.minY + canvasRect.height * 0.10), scale: 1.25)
        addTree(at: CGPoint(x: canvasRect.minX + canvasRect.width * 0.70, y: canvasRect.minY + canvasRect.height * 0.08), scale: 0.8)
    }

    private func addTree(at position: CGPoint, scale: CGFloat) {
        let tree = SKNode()
        tree.position = position
        tree.setScale(scale)
        let trunk = SKShapeNode(rect: CGRect(x: -5, y: 0, width: 10, height: 34))
        trunk.fillColor = SKColor(red: 0.26, green: 0.15, blue: 0.09, alpha: 1)
        trunk.strokeColor = .clear
        tree.addChild(trunk)
        tree.addChild(polygon([CGPoint(x: -28, y: 24), CGPoint(x: 0, y: 82), CGPoint(x: 28, y: 24)], color: SKColor(red: 0.08, green: 0.25, blue: 0.15, alpha: 1)))
        treeNode.addChild(tree)
    }

    private func reveal(_ progress: Double, from start: Double, to end: Double) -> CGFloat {
        CGFloat(min(max((progress - start) / (end - start), 0), 1))
    }

    private func polygon(_ points: [CGPoint], color: SKColor) -> SKShapeNode {
        let path = CGMutablePath()
        guard let first = points.first else { return SKShapeNode() }
        path.move(to: first)
        points.dropFirst().forEach { path.addLine(to: $0) }
        path.closeSubpath()
        let shape = SKShapeNode(path: path)
        shape.fillColor = color
        shape.strokeColor = .clear
        return shape
    }
}
