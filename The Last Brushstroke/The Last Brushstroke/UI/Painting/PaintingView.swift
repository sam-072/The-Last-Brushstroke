import SpriteKit
import SwiftUI

struct PaintingView: View {
    let coordinator: AppCoordinator

    @State private var scene = PaintingScene(
        size: .init(width: 1, height: 1)
    )

    @State private var refreshTask: Task<Void, Never>?

    var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: scene)
                .onAppear {
                    updateSceneSize(proxy.size)
                    renderCurrentState()
                    startRefreshLoop()
                }
                .onDisappear {
                    stopRefreshLoop()
                }
                .onChange(of: proxy.size) { _, newSize in
                    updateSceneSize(newSize)
                    renderCurrentState()
                }
                .onChange(of: coordinator.paintingState) {
                    renderCurrentState()
                }
        }
        .frame(minWidth: 720, minHeight: 480)
    }

    private func updateSceneSize(_ size: CGSize) {
        guard size.width > 0, size.height > 0 else {
            return
        }

        scene.size = size
    }

    private func renderCurrentState() {
        scene.render(state: coordinator.paintingState)
    }

    private func startRefreshLoop() {
        stopRefreshLoop()

        refreshTask = Task { @MainActor in
            while !Task.isCancelled {
                renderCurrentState()

                try? await Task.sleep(
                    nanoseconds: 100_000_000
                )
            }
        }
    }

    private func stopRefreshLoop() {
        refreshTask?.cancel()
        refreshTask = nil
    }
}
