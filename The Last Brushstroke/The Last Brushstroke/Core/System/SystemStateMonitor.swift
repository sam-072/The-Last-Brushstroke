import AppKit
import Foundation

@MainActor
final class SystemStateMonitor {
    private(set) var currentState: SystemState
    private var workspaceObservers: [NSObjectProtocol] = []
    private var distributedObservers: [NSObjectProtocol] = []

    var onStateChange: ((SystemState) -> Void)?

    init() {
        currentState = .awakeAndUnlocked
    }

    func start() {
        guard workspaceObservers.isEmpty && distributedObservers.isEmpty else {
            return
        }

        registerWorkspaceObservers()
        registerDistributedObservers()
    }

    func stop() {
        let workspaceCenter = NSWorkspace.shared.notificationCenter

        for observer in workspaceObservers {
            workspaceCenter.removeObserver(observer)
        }

        workspaceObservers.removeAll()

        let distributedCenter = DistributedNotificationCenter.default()

        for observer in distributedObservers {
            distributedCenter.removeObserver(observer)
        }

        distributedObservers.removeAll()
    }

    private func registerWorkspaceObservers() {
        let center = NSWorkspace.shared.notificationCenter

        let willSleepObserver = center.addObserver(
            forName: NSWorkspace.willSleepNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }

                self.updateState(
                    isLocked: self.currentState.isLocked,
                    isSleeping: true
                )
            }
        }

        let didWakeObserver = center.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }

                self.updateState(
                    isLocked: self.currentState.isLocked,
                    isSleeping: false
                )
            }
        }

        workspaceObservers.append(willSleepObserver)
        workspaceObservers.append(didWakeObserver)
    }

    private func registerDistributedObservers() {
        let center = DistributedNotificationCenter.default()

        let lockObserver = center.addObserver(
            forName: NSNotification.Name("com.apple.screenIsLocked"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.updateState(
                    isLocked: true,
                    isSleeping: false
                )
            }
        }

        let unlockObserver = center.addObserver(
            forName: NSNotification.Name("com.apple.screenIsUnlocked"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.updateState(
                    isLocked: false,
                    isSleeping: false
                )
            }
        }

        let screenSaverStartedObserver = center.addObserver(
            forName: NSNotification.Name("com.apple.screensaver.didstart"),
            object: nil,
            queue: .main
        ) { _ in }

        let screenSaverWillStopObserver = center.addObserver(
            forName: NSNotification.Name("com.apple.screensaver.willstop"),
            object: nil,
            queue: .main
        ) { _ in }

        let screenSaverDidStopObserver = center.addObserver(
            forName: NSNotification.Name("com.apple.screensaver.didstop"),
            object: nil,
            queue: .main
        ) { _ in }

        distributedObservers.append(lockObserver)
        distributedObservers.append(unlockObserver)
        distributedObservers.append(screenSaverStartedObserver)
        distributedObservers.append(screenSaverWillStopObserver)
        distributedObservers.append(screenSaverDidStopObserver)
    }

    private func updateState(
        isLocked: Bool,
        isSleeping: Bool
    ) {
        let newState = SystemState(
            isLocked: isLocked,
            isSleeping: isSleeping
        )

        guard newState != currentState else {
            return
        }

        currentState = newState
        onStateChange?(newState)
    }
}
