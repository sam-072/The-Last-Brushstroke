import Foundation

struct FileStorage {
    private let fileURL: URL

    init(
        fileName: String = "painting-state.json",
        fileManager: FileManager = .default
    ) throws {
        let applicationSupportDirectory = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let applicationDirectory = applicationSupportDirectory
            .appendingPathComponent("The Last Brushstroke", isDirectory: true)

        try fileManager.createDirectory(
            at: applicationDirectory,
            withIntermediateDirectories: true
        )

        self.fileURL = applicationDirectory
            .appendingPathComponent(fileName)
    }

    func save<T: Encodable>(_ value: T) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(value)

        try data.write(
            to: fileURL,
            options: [.atomic]
        )
    }

    func load<T: Decodable>(_ type: T.Type) throws -> T {
        let data = try Data(contentsOf: fileURL)

        let decoder = JSONDecoder()

        return try decoder.decode(type, from: data)
    }

    func exists() -> Bool {
        FileManager.default.fileExists(atPath: fileURL.path)
    }

    func delete() throws {
        guard exists() else {
            return
        }

        try FileManager.default.removeItem(at: fileURL)
    }
}