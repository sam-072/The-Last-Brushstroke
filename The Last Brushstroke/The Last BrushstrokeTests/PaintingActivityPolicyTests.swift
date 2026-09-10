//
//  PaintingActivityPolicyTests.swift
//  The Last BrushstrokeTests
//

@testable import The_Last_Brushstroke
import XCTest

final class PaintingActivityPolicyTests: XCTestCase {

    func testLockOnlyAllowsPaintingWhenLockedAndNotSleeping() {
        let policy = PaintingActivityPolicy.lockOnly

        XCTAssertTrue(
            policy.shouldPaint(
                isLocked: true,
                isSleeping: false
            )
        )
    }

    func testLockOnlyStopsPaintingWhenUnlocked() {
        let policy = PaintingActivityPolicy.lockOnly

        XCTAssertFalse(
            policy.shouldPaint(
                isLocked: false,
                isSleeping: false
            )
        )
    }

    func testLockOnlyStopsPaintingWhenSleeping() {
        let policy = PaintingActivityPolicy.lockOnly

        XCTAssertFalse(
            policy.shouldPaint(
                isLocked: true,
                isSleeping: true
            )
        )
    }

    func testAlwaysActiveAllowsPaintingWhenUnlocked() {
        let policy = PaintingActivityPolicy.alwaysActive

        XCTAssertTrue(
            policy.shouldPaint(
                isLocked: false,
                isSleeping: false
            )
        )
    }

    func testAlwaysActiveAllowsPaintingWhenLocked() {
        let policy = PaintingActivityPolicy.alwaysActive

        XCTAssertTrue(
            policy.shouldPaint(
                isLocked: true,
                isSleeping: false
            )
        )
    }

    func testAlwaysActiveStopsPaintingDuringSleep() {
        let policy = PaintingActivityPolicy.alwaysActive

        XCTAssertFalse(
            policy.shouldPaint(
                isLocked: false,
                isSleeping: true
            )
        )
    }
}
