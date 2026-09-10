//
//  AppCoordinator.swift
//  The Last Brushstroke
//

import Foundation
import Observation

@MainActor
@Observable
final class AppCoordinator {

    let engine: PaintingEngine

    private let persistence: any PersistenceService

    init(requiredDuration: TimeInterval = 3_600) {
        self.engine = PaintingEngine(
            requiredDuration: requiredDuration
        )

        do {
            self.persistence = try LocalPersistenceService()
        } catch {
            fatalError(
                "Failed to initialize persistence: \(error)"
            )
        }

        restorePaintingState()
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
            print(
                "Failed to save painting state: \(error)"
            )
        }
    }

    private func restorePaintingState() {
        do {
            try engine.restore(using: persistence)
        } catch {
            print(
                "Failed to restore painting state: \(error)"
            )
        }
    }
}

