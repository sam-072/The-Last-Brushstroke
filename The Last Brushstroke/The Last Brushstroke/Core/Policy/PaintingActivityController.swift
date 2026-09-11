import Foundation

@MainActor
final class PaintingActivityController {
    private let engine: PaintingEngine
    private let systemStateMonitor: SystemStateMonitor

    var onStateChange: (() -> Void)?

    init(
        engine: PaintingEngine,
        systemStateMonitor: SystemStateMonitor
    ) {
        self.engine = engine
        self.systemStateMonitor = systemStateMonitor

        systemStateMonitor.onStateChange = { [weak self] state in
            self?.handle(systemState: state)
        }
    }

    func start() {
        systemStateMonitor.start()
        handle(systemState: systemStateMonitor.currentState)
    }

    func stop() {
        systemStateMonitor.stop()
    }

    private func handle(systemState: SystemState) {
        let previousState = engine.state

        engine.updateActivity(
            isLocked: systemState.isLocked,
            isSleeping: systemState.isSleeping
        )

        let newState = engine.state

        if previousState != newState {
            onStateChange?()
        }
    }
}
