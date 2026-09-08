//
//  PaintingEngineTests.swift
//  The Last BrushstrokeTests
//

@testable import The_Last_Brushstroke
import XCTest

@MainActor
final class PaintingEngineTests: XCTestCase {
    func testClockAccumulatesOnlyWhileRunning() {
        let timeSource = TestTimeSource()
        let clock = PaintingClock(timeSource: timeSource)

        clock.start()
        timeSource.advance(by: 30)
        XCTAssertEqual(clock.accumulatedDuration, 30)

        clock.pause()
        timeSource.advance(by: 30)
        XCTAssertEqual(clock.accumulatedDuration, 30)

        clock.resume()
        timeSource.advance(by: 30)
        clock.pause()
        XCTAssertEqual(clock.accumulatedDuration, 60)
    }

    func testClockResetClearsDurationAndStopsRunning() {
        let timeSource = TestTimeSource()
        let clock = PaintingClock(timeSource: timeSource)

        clock.start()
        timeSource.advance(by: 20)
        clock.reset()

        XCTAssertEqual(clock.accumulatedDuration, 0)
        XCTAssertFalse(clock.isRunning)
    }

    func testProgressCalculatorClampsProgress() {
        let calculator = PaintingProgressCalculator(requiredDuration: 100)

        XCTAssertEqual(calculator.progress(for: 0), 0)
        XCTAssertEqual(calculator.progress(for: 50), 0.5, accuracy: 0.000_001)
        XCTAssertEqual(calculator.progress(for: 100), 1)
        XCTAssertEqual(calculator.progress(for: 150), 1)
    }

    func testEngineStartsPausesAndResumesWithoutCountingPausedTime() {
        let timeSource = TestTimeSource()
        let engine = PaintingEngine(requiredDuration: 100, timeSource: timeSource)

        XCTAssertEqual(engine.state.status, .idle)
        XCTAssertEqual(engine.state.progress, 0)

        engine.start()
        XCTAssertEqual(engine.state.status, .painting)

        timeSource.advance(by: 30)
        engine.pause()
        XCTAssertEqual(engine.state.status, .paused)
        XCTAssertEqual(engine.state.accumulatedDuration, 30)

        timeSource.advance(by: 40)
        XCTAssertEqual(engine.state.accumulatedDuration, 30)

        engine.resume()
        XCTAssertEqual(engine.state.status, .painting)
        timeSource.advance(by: 20)
        engine.pause()

        XCTAssertEqual(engine.state.accumulatedDuration, 50)
        XCTAssertEqual(engine.state.progress, 0.5, accuracy: 0.000_001)
    }

    func testEngineCompletesWhenProgressReachesRequiredDuration() {
        let timeSource = TestTimeSource()
        let engine = PaintingEngine(requiredDuration: 100, timeSource: timeSource)

        engine.start()
        timeSource.advance(by: 100)

        XCTAssertEqual(engine.state.status, .completed)
        XCTAssertEqual(engine.state.progress, 1)
    }

    func testEngineCompleteForcesCompletedState() {
        let engine = PaintingEngine(requiredDuration: 100, timeSource: TestTimeSource())

        engine.start()
        engine.complete()

        XCTAssertEqual(engine.state.status, .completed)
        XCTAssertEqual(engine.state.progress, 1)
    }

    func testEngineRestoresPausedState() {
        let timeSource = TestTimeSource()
        let engine = PaintingEngine(requiredDuration: 100, timeSource: timeSource)

        engine.restore(
            state: PaintingState(status: .paused, accumulatedDuration: 25, progress: 0.25)
        )

        XCTAssertEqual(engine.state.status, .paused)
        XCTAssertEqual(engine.state.accumulatedDuration, 25)
        XCTAssertEqual(engine.state.progress, 0.25, accuracy: 0.000_001)
    }
}

@MainActor
private final class TestTimeSource: PaintingTimeSource {
    private var currentTime: TimeInterval = 0

    func now() -> TimeInterval {
        currentTime
    }

    func advance(by duration: TimeInterval) {
        currentTime += duration
    }
}
