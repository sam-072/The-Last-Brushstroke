//
//  PaintingEngine.swift
//  The Last Brushstroke
//

import Foundation

final class PaintingEngine {
    private let clock: PaintingClock
    private let progressCalculator: PaintingProgressCalculator
    private var status: PaintingStatus = .idle

    init(
        requiredDuration: TimeInterval,
        timeSource: any PaintingTimeSource = SystemUptimeTimeSource()
    ) {
        clock = PaintingClock(timeSource: timeSource)
        progressCalculator = PaintingProgressCalculator(requiredDuration: requiredDuration)
    }

    var state: PaintingState {
        updateCompletionIfNeeded()
        return makeState()
    }

    func start() {
        guard status == .idle else { return }
        clock.start()
        status = .painting
    }

    func pause() {
        updateCompletionIfNeeded()
        guard status == .painting else { return }
        clock.pause()
        status = .paused
    }

    func resume() {
        guard status == .paused else { return }
        clock.resume()
        status = .painting
    }

    func complete() {
        clock.pause()
        status = .completed
    }

    func restore(state: PaintingState) {
        status = state.status
        clock.restore(
            accumulatedDuration: state.accumulatedDuration,
            isRunning: state.status == .painting
        )
        updateCompletionIfNeeded()
    }

    private func updateCompletionIfNeeded() {
        guard status == .painting, progressCalculator.isComplete(for: clock.accumulatedDuration) else { return }
        clock.pause()
        status = .completed
    }

    private func makeState() -> PaintingState {
        let accumulatedDuration = clock.accumulatedDuration
        let progress = status == .completed
            ? 1
            : progressCalculator.progress(for: accumulatedDuration)

        return PaintingState(
            status: status,
            accumulatedDuration: accumulatedDuration,
            progress: progress
        )
    }
}
