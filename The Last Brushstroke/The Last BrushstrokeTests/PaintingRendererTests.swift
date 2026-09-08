//
//  PaintingRendererTests.swift
//  The Last BrushstrokeTests
//

@testable import The_Last_Brushstroke
import XCTest

@MainActor
final class PaintingRendererTests: XCTestCase {
    func testVisualStagesMapToExpectedProgressRanges() {
        XCTAssertEqual(PaintingVisualStage(progress: 0), .blank)
        XCTAssertEqual(PaintingVisualStage(progress: 0.25), .mountains)
        XCTAssertEqual(PaintingVisualStage(progress: 0.5), .ground)
        XCTAssertEqual(PaintingVisualStage(progress: 0.75), .trees)
        XCTAssertEqual(PaintingVisualStage(progress: 1), .completed)
    }

    func testSceneReceivesPaintingStateAndTracksItsVisualStage() {
        let scene = PaintingScene(size: CGSize(width: 800, height: 600))

        scene.render(state: PaintingState(status: .paused, accumulatedDuration: 50, progress: 0.5))

        XCTAssertEqual(scene.renderedStage, .ground)
    }

    func testPainterAnimationMatchesPaintingStatus() {
        let painter = PainterNode()
        let controller = PainterAnimationController(painter: painter)

        controller.update(for: .idle)
        XCTAssertFalse(controller.isAnimating)
        XCTAssertTrue(painter.isHidden)

        controller.update(for: .painting)
        XCTAssertTrue(controller.isAnimating)
        XCTAssertFalse(painter.isHidden)

        controller.update(for: .paused)
        XCTAssertFalse(controller.isAnimating)
        XCTAssertFalse(painter.isHidden)

        controller.update(for: .completed)
        XCTAssertFalse(controller.isAnimating)
        XCTAssertFalse(painter.isHidden)
    }
}
