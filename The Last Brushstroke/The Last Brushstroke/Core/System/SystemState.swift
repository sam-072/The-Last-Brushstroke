//
//  SystemState.swift
//  The Last Brushstroke
//

import Foundation

struct SystemState: Equatable {

    let isLocked: Bool
    let isSleeping: Bool

    static let awakeAndUnlocked = SystemState(
        isLocked: false,
        isSleeping: false
    )

    static let awakeAndLocked = SystemState(
        isLocked: true,
        isSleeping: false
    )

    static let sleeping = SystemState(
        isLocked: false,
        isSleeping: true
    )
}
