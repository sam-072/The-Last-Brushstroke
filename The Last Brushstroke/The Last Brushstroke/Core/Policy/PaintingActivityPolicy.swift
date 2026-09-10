//
//  PaintingActivityPolicy.swift
//  The Last Brushstroke
//

import Foundation

enum PaintingActivityPolicy: String, Codable, Equatable {
    case lockOnly
    case alwaysActive

    func shouldPaint(
        isLocked: Bool,
        isSleeping: Bool
    ) -> Bool {
        switch self {
        case .lockOnly:
            return isLocked && !isSleeping

        case .alwaysActive:
            return !isSleeping
        }
    }
}
