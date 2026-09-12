import Cocoa
import ScreenSaver
import SpriteKit

final class LastBrushstrokeScreenSaverView: ScreenSaverView {

    private let engine: PaintingEngine
    private let scene: PaintingScene

    private var spriteView: SKView?
    private var persistence: LocalPersistenceService?

    private var frameCounter = 0

    private let requiredPaintingDuration: TimeInterval = 3_600

    override var isOpaque: Bool {
        true
    }

    override init?(frame: NSRect, isPreview: Bool) {
        self.engine = PaintingEngine(
            requiredDuration: 3_600,
            activityPolicy: .lockOnly
        )

        self.scene = PaintingScene(
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
        self.engine = PaintingEngine(
            requiredDuration: 3_600,
            activityPolicy: .lockOnly
        )

        self.scene = PaintingScene(
            size: .zero
        )

        super.init(coder: coder)
    }

    override func startAnimation() {
        super.startAnimation()

        restorePaintingState()

        startPaintingIfNeeded()
    }

    override func animateOneFrame() {
        super.animateOneFrame()

        renderCurrentState()

        frameCounter += 1

        if frameCounter >= 50 {
            frameCounter = 0
            savePaintingState()
        }
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

        view.presentScene(scene)

        if isPreview {
            scene.scaleMode = .aspectFill
        } else {
            scene.scaleMode = .resizeFill
        }
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

        renderCurrentState()
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
                "Screen Saver failed to restore painting state: \(error)"
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
                "Screen Saver failed to save painting state: \(error)"
            )
        }
    }
}
