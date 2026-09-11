//
//  SystemStateTests.swift
//  The Last BrushstrokeTests
//

@testable import The_Last_Brushstroke
import XCTest

final class SystemStateTests: XCTestCase {

    func testAwakeAndUnlockedState() {
        let state = SystemState.awakeAndUnlocked

        XCTAssertFalse(state.isLocked)
        XCTAssertFalse(state.isSleeping)
    }

    func testAwakeAndLockedState() {
        let state = SystemState.awakeAndLocked

        XCTAssertTrue(state.isLocked)
        XCTAssertFalse(state.isSleeping)
    }

    func testSleepingState() {
        let state = SystemState.sleeping

        XCTAssertTrue(
            state.isSleeping
        )
    }

    func testSystemStatesAreEquatable() {
        XCTAssertEqual(
            SystemState.awakeAndUnlocked,
            SystemState.awakeAndUnlocked
        )

        XCTAssertNotEqual(
            SystemState.awakeAndUnlocked,
            SystemState.awakeAndLocked
        )

        XCTAssertNotEqual(
            SystemState.awakeAndLocked,
            SystemState.sleeping
        )
    }
}
