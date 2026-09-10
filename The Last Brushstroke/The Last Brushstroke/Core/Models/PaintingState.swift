import Foundation

struct PaintingState: Codable, Equatable {
    let status: PaintingStatus
    let accumulatedDuration: TimeInterval
    let progress: Double
}