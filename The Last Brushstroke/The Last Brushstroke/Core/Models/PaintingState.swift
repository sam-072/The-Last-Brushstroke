//
//  PaintingState.swift
//  The Last Brushstroke
//

import Foundation

struct PaintingState: Equatable {
    let status: PaintingStatus
    let accumulatedDuration: TimeInterval
    let progress: Double
}
