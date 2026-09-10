import Foundation

protocol PersistenceService {
    func save(_ state: PaintingState) throws
    func load() throws -> PaintingState?
    func delete() throws
}

final class LocalPersistenceService: PersistenceService {
    private let storage: FileStorage

    init(storage: FileStorage? = nil) throws {
        self.storage = try storage ?? FileStorage()
    }

    func save(_ state: PaintingState) throws {
        try storage.save(state)
    }

    func load() throws -> PaintingState? {
        guard storage.exists() else {
            return nil
        }

        return try storage.load(PaintingState.self)
    }

    func delete() throws {
        try storage.delete()
    }
}
