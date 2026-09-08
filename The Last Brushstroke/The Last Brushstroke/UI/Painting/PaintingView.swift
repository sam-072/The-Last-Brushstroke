//
//  PaintingView.swift
//  The Last Brushstroke
//

import SpriteKit
import SwiftUI

struct PaintingView: View {
    @State private var engine = PaintingEngine(requiredDuration: 3_600)
    @State private var scene = PaintingScene(size: .init(width: 1, height: 1))

    var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: scene)
                .onAppear {
                    updateSceneSize(proxy.size)
                    renderCurrentState()
                }
                .onChange(of: proxy.size) { _, newSize in
                    updateSceneSize(newSize)
                    renderCurrentState()
                }
        }
        .frame(minWidth: 720, minHeight: 480)
    }

    private func updateSceneSize(_ size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        scene.size = size
    }

    private func renderCurrentState() {
        scene.render(state: engine.state)
    }
}

#Preview {
    PaintingView()
}
