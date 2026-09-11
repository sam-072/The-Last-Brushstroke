import Foundation
import Observation

@MainActor
@Observable
final class AppCoordinator {
    let engine: PaintingEngine
    private let persistence: any PersistenceService
    private let activityController: PaintingActivityController

    init(requiredDuration: TimeInterval = 3_600) {
        let engine = PaintingEngine(requiredDuration: requiredDuration)

        do {
            let persistence = try LocalPersistenceService()
            self.engine = engine
            self.persistence = persistence
        } catch {
            fatalError("Failed to initialize persistence: \(error)")
        }

        let systemStateMonitor = SystemStateMonitor()

        let activityController = PaintingActivityController(
            engine: engine,
            systemStateMonitor: systemStateMonitor
        )

        self.activityController = activityController

        activityController.onStateChange = { [weak self] in
            self?.savePaintingState()
        }

        restorePaintingState()
        activityController.start()
    }

    var paintingState: PaintingState {
        engine.state
    }

    func startPainting() {
        engine.start()
        savePaintingState()
    }

    func pausePainting() {
        engine.pause()
        savePaintingState()
    }

    func resumePainting() {
        engine.resume()
        savePaintingState()
    }

    func completePainting() {
        engine.complete()
        savePaintingState()
    }

    func savePaintingState() {
        do {
            try engine.save(using: persistence)
        } catch {
            print("Failed to save painting state: \(error)")
        }
    }

    private func restorePaintingState() {
        do {
            try engine.restore(using: persistence)
        } catch {
            print("Failed to restore painting state: \(error)")
        }
    }
}
