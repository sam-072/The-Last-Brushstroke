import Cocoa
import ScreenSaver
import SpriteKit

final class LastBrushstrokeScreenSaverView: ScreenSaverView {

    private let engine: PaintingEngine
    private let scene: PaintingScene

    private var spriteView: SKView?
    private var persistence: LocalPersistenceService?

    private let requiredPaintingDuration: TimeInterval = 3_600

    override var isOpaque: Bool {
        true
    }

    override init?(
        frame: NSRect,
        isPreview: Bool
    ) {
        engine = PaintingEngine(
            requiredDuration: 3_600
        )

        scene = PaintingScene(
            size: frame.size
        )

        super.init(
            frame: frame,
            isPreview: isPreview
        )

        configureView(
            frame: frame,
            isPreview: isPreview
        )
    }

    required init?(coder: NSCoder) {
        engine = PaintingEngine(
            requiredDuration: 3_600
        )

        scene = PaintingScene(
            size: .zero
        )

        super.init(coder: coder)
    }

    override func startAnimation() {
        super.startAnimation()

        restorePaintingState()

        startPaintingIfNeeded()

        renderCurrentState()
    }

    override func animateOneFrame() {
        super.animateOneFrame()

        renderCurrentState()
    }

    override func stopAnimation() {
        savePaintingState()

        engine.pause()

        savePaintingState()

        super.stopAnimation()
    }

    override func draw(_ rect: NSRect) {
        super.draw(rect)

        renderCurrentState()
    }

    private func configureView(
        frame: NSRect,
        isPreview: Bool
    ) {
        animationTimeInterval = 0.1

        wantsLayer = true

        let view = SKView(
            frame: bounds
        )

        view.autoresizingMask = [
            .width,
            .height
        ]

        view.ignoresSiblingOrder = true

        addSubview(view)

        spriteView = view

        scene.size = bounds.size

        if isPreview {
            scene.scaleMode = .aspectFill
        } else {
            scene.scaleMode = .resizeFill
        }

        view.presentScene(scene)
    }

    private func startPaintingIfNeeded() {
        switch engine.state.status {

        case .idle:
            engine.start()

        case .paused:
            engine.resume()

        case .painting:
            break

        case .completed:
            break
        }
    }

    private func renderCurrentState() {
        guard bounds.width > 0,
              bounds.height > 0
        else {
            return
        }

        if scene.size != bounds.size {
            scene.size = bounds.size
        }

        scene.render(
            state: engine.state
        )
    }

    private func restorePaintingState() {
        do {
            if persistence == nil {
                persistence = try LocalPersistenceService()
            }

            guard let persistence else {
                return
            }

            try engine.restore(
                using: persistence
            )

        } catch {
            print(
                "Failed to restore painting state: \(error)"
            )
        }
    }

    private func savePaintingState() {
        do {
            if persistence == nil {
                persistence = try LocalPersistenceService()
            }

            guard let persistence else {
                return
            }

            try engine.save(
                using: persistence
            )

        } catch {
            print(
                "Failed to save painting state: \(error)"
            )
        }
    }
}
