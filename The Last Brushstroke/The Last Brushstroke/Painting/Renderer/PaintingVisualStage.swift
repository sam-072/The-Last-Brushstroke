//
//  PaintingVisualStage.swift
//  The Last Brushstroke
//

enum PaintingVisualStage: Equatable {
    case blank, sky, mountains, ground, trees, details, completed

    init(progress: Double) {
        switch progress {
        case ...0: self = .blank
        case ..<0.2: self = .sky
        case ..<0.4: self = .mountains
        case ..<0.6: self = .ground
        case ..<0.8: self = .trees
        case ..<1: self = .details
        default: self = .completed
        }
    }
}
