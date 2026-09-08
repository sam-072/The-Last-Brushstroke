//
//  PainterNode.swift
//  The Last Brushstroke
//

import SpriteKit

final class PainterNode: SKNode {
    let armNode = SKNode()

    override init() {
        super.init()
        zPosition = 10
        buildPainter()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildPainter()
    }

    func resetPose() {
        armNode.zRotation = 0
    }

    private func buildPainter() {
        let body = SKShapeNode(rectOf: CGSize(width: 34, height: 52), cornerRadius: 10)
        body.position = CGPoint(x: 0, y: 30)
        body.fillColor = SKColor(red: 0.23, green: 0.28, blue: 0.38, alpha: 1)
        body.strokeColor = .clear
        addChild(body)

        let head = SKShapeNode(circleOfRadius: 16)
        head.position = CGPoint(x: 0, y: 70)
        head.fillColor = SKColor(red: 0.90, green: 0.67, blue: 0.48, alpha: 1)
        head.strokeColor = .clear
        addChild(head)

        armNode.position = CGPoint(x: 14, y: 48)
        let arm = SKShapeNode(rectOf: CGSize(width: 32, height: 10), cornerRadius: 5)
        arm.position = CGPoint(x: 16, y: 0)
        arm.fillColor = SKColor(red: 0.90, green: 0.67, blue: 0.48, alpha: 1)
        arm.strokeColor = .clear
        armNode.addChild(arm)

        let brush = SKShapeNode(rectOf: CGSize(width: 28, height: 5), cornerRadius: 2)
        brush.position = CGPoint(x: 36, y: -4)
        brush.fillColor = SKColor(red: 0.29, green: 0.16, blue: 0.08, alpha: 1)
        brush.strokeColor = .clear
        armNode.addChild(brush)
        addChild(armNode)
    }
}
