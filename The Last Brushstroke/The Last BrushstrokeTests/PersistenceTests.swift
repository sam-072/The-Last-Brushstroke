//
//  PersistenceTests.swift
//  The Last BrushstrokeTests
//

@testable import The_Last_Brushstroke
import XCTest

@MainActor
final class PersistenceTests: XCTestCase {

    func testPaintingStateCanBeSavedAndLoaded() throws {
        let temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        try FileManager.default.createDirectory(
            at: temporaryDirectory,
            withIntermediateDirectories: true
        )

        defer {
            try? FileManager.default.removeItem(at: temporaryDirectory)
        }

        let fileURL = temporaryDirectory
            .appendingPathComponent("painting-state.json")

        let storage = TestFileStorage(
            fileURL: fileURL
        )

        let persistence = TestPersistenceService(
            storage: storage
        )

        let originalState = PaintingState(
            status: .paused,
            accumulatedDuration: 123.45,
            progress: 0.03429166666666667
        )

        try persistence.save(
            originalState
        )

        let restoredState = try persistence.load()

        XCTAssertEqual(
            restoredState,
            originalState
        )
    }

    func testLoadReturnsNilWhenNoPaintingStateExists() throws {
        let temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        try FileManager.default.createDirectory(
            at: temporaryDirectory,
            withIntermediateDirectories: true
        )

        defer {
            try? FileManager.default.removeItem(at: temporaryDirectory)
        }

        let fileURL = temporaryDirectory
            .appendingPathComponent("painting-state.json")

        let storage = TestFileStorage(
            fileURL: fileURL
        )

        let persistence = TestPersistenceService(
            storage: storage
        )

        let restoredState = try persistence.load()

        XCTAssertNil(
            restoredState
        )
    }

    func testEngineCanSaveAndRestorePausedState() throws {
        let timeSource = TestTimeSource()

        let engine = PaintingEngine(
            requiredDuration: 100,
            timeSource: timeSource
        )

        let temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        try FileManager.default.createDirectory(
            at: temporaryDirectory,
            withIntermediateDirectories: true
        )

        defer {
            try? FileManager.default.removeItem(at: temporaryDirectory)
        }

        let fileURL = temporaryDirectory
            .appendingPathComponent("painting-state.json")

        let storage = TestFileStorage(
            fileURL: fileURL
        )

        let persistence = TestPersistenceService(
            storage: storage
        )

        engine.start()

        timeSource.advance(
            by: 35
        )

        engine.pause()

        try engine.save(
            using: persistence
        )

        let restoredEngine = PaintingEngine(
            requiredDuration: 100,
            timeSource: timeSource
        )

        try restoredEngine.restore(
            using: persistence
        )

        XCTAssertEqual(
            restoredEngine.state.status,
            .paused
        )

        XCTAssertEqual(
            restoredEngine.state.accumulatedDuration,
            35,
            accuracy: 0.000001
        )

        XCTAssertEqual(
            restoredEngine.state.progress,
            0.35,
            accuracy: 0.000001
        )
    }

    func testEngineCanSaveAndRestoreCompletedState() throws {
        let timeSource = TestTimeSource()

        let engine = PaintingEngine(
            requiredDuration: 100,
            timeSource: timeSource
        )

        let temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        try FileManager.default.createDirectory(
            at: temporaryDirectory,
            withIntermediateDirectories: true
        )

        defer {
            try? FileManager.default.removeItem(at: temporaryDirectory)
        }

        let fileURL = temporaryDirectory
            .appendingPathComponent("painting-state.json")

        let storage = TestFileStorage(
            fileURL: fileURL
        )

        let persistence = TestPersistenceService(
            storage: storage
        )

        engine.start()

        timeSource.advance(
            by: 100
        )

        XCTAssertEqual(
            engine.state.status,
            .completed
        )

        try engine.save(
            using: persistence
        )

        let restoredEngine = PaintingEngine(
            requiredDuration: 100,
            timeSource: timeSource
        )

        try restoredEngine.restore(
            using: persistence
        )

        XCTAssertEqual(
            restoredEngine.state.status,
            .completed
        )

        XCTAssertEqual(
            restoredEngine.state.accumulatedDuration,
            100,
            accuracy: 0.000001
        )

        XCTAssertEqual(
            restoredEngine.state.progress,
            1,
            accuracy: 0.000001
        )
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

private final class TestFileStorage {

    private let fileURL: URL

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func save<T: Encodable>(
        _ value: T
    ) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys
        ]

        let data = try encoder.encode(
            value
        )

        try data.write(
            to: fileURL,
            options: [.atomic]
        )
    }

    func load<T: Decodable>(
        _ type: T.Type
    ) throws -> T {
        let data = try Data(
            contentsOf: fileURL
        )

        let decoder = JSONDecoder()

        return try decoder.decode(
            type,
            from: data
        )
    }

    func exists() -> Bool {
        FileManager.default.fileExists(
            atPath: fileURL.path
        )
    }
}

private final class TestPersistenceService: PersistenceService {

    private let storage: TestFileStorage

    init(storage: TestFileStorage) {
        self.storage = storage
    }

    func save(
        _ state: PaintingState
    ) throws {
        try storage.save(
            state
        )
    }

    func load() throws -> PaintingState? {
        guard storage.exists() else {
            return nil
        }

        return try storage.load(
            PaintingState.self
        )
    }

    func delete() throws {
        // Not required by these tests.
    }
}
