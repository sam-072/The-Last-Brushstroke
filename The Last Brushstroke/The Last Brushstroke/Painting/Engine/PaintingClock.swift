//
//  PaintingClock.swift
//  The Last Brushstroke
//

import Foundation

protocol PaintingTimeSource {
    func now() -> TimeInterval
}

struct SystemUptimeTimeSource: PaintingTimeSource {
    func now() -> TimeInterval {
        ProcessInfo.processInfo.systemUptime
    }
}

final class PaintingClock {
    private let timeSource: any PaintingTimeSource
    private var storedDuration: TimeInterval = 0
    private var startedAt: TimeInterval?

    init(timeSource: any PaintingTimeSource = SystemUptimeTimeSource()) {
        self.timeSource = timeSource
    }

    var accumulatedDuration: TimeInterval {
        guard let startedAt else { return storedDuration }
        return storedDuration + max(0, timeSource.now() - startedAt)
    }

    var isRunning: Bool {
        startedAt != nil
    }

    func start() {
        storedDuration = 0
        startedAt = timeSource.now()
    }

    func pause() {
        guard let startedAt else { return }
        storedDuration += max(0, timeSource.now() - startedAt)
        self.startedAt = nil
    }

    func resume() {
        guard !isRunning else { return }
        startedAt = timeSource.now()
    }

    func reset() {
        storedDuration = 0
        startedAt = nil
    }

    func restore(accumulatedDuration: TimeInterval, isRunning: Bool) {
        storedDuration = max(0, accumulatedDuration)
        startedAt = isRunning ? timeSource.now() : nil
    }
}
