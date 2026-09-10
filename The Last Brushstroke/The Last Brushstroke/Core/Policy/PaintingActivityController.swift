//
//  PaintingActivityController.swift
//  The Last Brushstroke
//

import Foundation

@MainActor
final class PaintingActivityController {

    private let engine: PaintingEngine

    init(engine: PaintingEngine) {
        self.engine = engine
    }

    func update(
        isLocked: Bool,
        isSleeping: Bool
    ) {
        engine.updateActivity(
            isLocked: isLocked,
            isSleeping: isSleeping
        )
    }
}
