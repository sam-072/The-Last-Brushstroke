//
//  PaintingEngine.swift
//  The Last Brushstroke
//

import Foundation

final class PaintingEngine {

    private let clock: PaintingClock
    private let progressCalculator: PaintingProgressCalculator
    private let activityPolicy: PaintingActivityPolicy

    private var status: PaintingStatus = .idle

    init(
        requiredDuration: TimeInterval,
        activityPolicy: PaintingActivityPolicy = .lockOnly,
        timeSource: any PaintingTimeSource = SystemUptimeTimeSource()
    ) {
        clock = PaintingClock(
            timeSource: timeSource
        )

        progressCalculator = PaintingProgressCalculator(
            requiredDuration: requiredDuration
        )

        self.activityPolicy = activityPolicy
    }

    var state: PaintingState {
        updateCompletionIfNeeded()
        return makeState()
    }

    func start() {
        guard status == .idle else {
            return
        }

        clock.start()
        status = .painting
    }

    func pause() {
        updateCompletionIfNeeded()

        guard status == .painting else {
            return
        }

        clock.pause()
        status = .paused
    }

    func resume() {
        guard status == .paused else {
            return
        }

        clock.resume()
        status = .painting
    }

    func complete() {
        clock.pause()
        status = .completed
    }

    func updateActivity(
        isLocked: Bool,
        isSleeping: Bool
    ) {
        guard status != .completed else {
            return
        }

        let shouldPaint = activityPolicy.shouldPaint(
            isLocked: isLocked,
            isSleeping: isSleeping
        )

        if shouldPaint {
            resumeIfNeeded()
        } else {
            pauseIfNeeded()
        }

        updateCompletionIfNeeded()
    }

    func save(
        using persistence: any PersistenceService
    ) throws {
        try persistence.save(
            state
        )
    }

    func restore(
        using persistence: any PersistenceService
    ) throws {
        guard let savedState = try persistence.load() else {
            return
        }

        restore(
            state: savedState
        )
    }

    func restore(
        state: PaintingState
    ) {
        status = state.status

        clock.restore(
            accumulatedDuration: state.accumulatedDuration,
            isRunning: state.status == .painting
        )

        updateCompletionIfNeeded()
    }

    private func resumeIfNeeded() {
        switch status {
        case .idle:
            start()

        case .paused:
            resume()

        case .painting, .completed:
            break
        }
    }

    private func pauseIfNeeded() {
        guard status == .painting else {
            return
        }

        clock.pause()
        status = .paused
    }

    private func updateCompletionIfNeeded() {
        guard status == .painting else {
            return
        }

        guard progressCalculator.isComplete(
            for: clock.accumulatedDuration
        ) else {
            return
        }

        clock.pause()
        status = .completed
    }

    private func makeState() -> PaintingState {
        let accumulatedDuration = clock.accumulatedDuration

        let progress = status == .completed
            ? 1
            : progressCalculator.progress(
                for: accumulatedDuration
            )

        return PaintingState(
            status: status,
            accumulatedDuration: accumulatedDuration,
            progress: progress
        )
    }
}
