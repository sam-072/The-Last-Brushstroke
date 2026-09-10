import Foundation

enum PaintingStatus: String, Codable, Equatable {
    case idle
    case painting
    case paused
    case completed
}