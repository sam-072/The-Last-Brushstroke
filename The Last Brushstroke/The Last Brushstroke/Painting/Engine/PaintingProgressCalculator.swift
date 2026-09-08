//
//  PaintingProgressCalculator.swift
//  The Last Brushstroke
//

import Foundation

struct PaintingProgressCalculator {
    let requiredDuration: TimeInterval

    init(requiredDuration: TimeInterval) {
        precondition(requiredDuration > 0, "The required painting duration must be positive.")
        self.requiredDuration = requiredDuration
    }

    func progress(for accumulatedDuration: TimeInterval) -> Double {
        min(max(accumulatedDuration / requiredDuration, 0), 1)
    }

    func isComplete(for accumulatedDuration: TimeInterval) -> Bool {
        progress(for: accumulatedDuration) == 1
    }
}
