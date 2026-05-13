import SwiftUI
import SpriteKit

// [Positive Transfer] This Swift migration preserves the core logic of random grayscale and alpha transitions.
// [New Fact] In Swift/SpriteKit, we use SKSpriteNode instead of Unity's SpriteRenderer.
// [New Fact] We use Timer for frame updates instead of Unity's Update loop.
// [Negative Transfer] Unity's Time.deltaTime is replaced with a custom time-based delta calculation.

/// A component that applies random grayscale and alpha transitions to a sprite.
struct RandomSpriteEffect: View {
    // MARK: - Properties
    
    /// Minimum grayscale value (0.0 = black, 1.0 = white)
    @State private var minGrayScale: Float = 0.0
    
    /// Maximum grayscale value (0.0 = black, 1.0 = white)
    @State private var maxGrayScale: Float = 1.0
    
    /// Minimum alpha value (0.0 = transparent, 1.0 = opaque)
    @State private var minAlpha: Float = 0.0
    
    /// Maximum alpha value (0.0 = transparent, 1.0 = opaque)
    @State private var maxAlpha: Float = 1.0
    
    /// Transition speed (higher = faster)
    @State private var transitionSpeed: Float = 0.5
    
    /// Current target grayscale value
    @State private var targetGrayScale: Float = 0.0
    
    /// Current target alpha value
    @State private var targetAlpha: Float = 1.0
    
    /// The SKSpriteNode representing the sprite
    @State private var spriteNode: SKSpriteNode?
    
    /// Timer used to simulate Unity's Update loop
    @State private var timer: Timer?
    
    /// Whether the effect is active
    @State private var isActive: Bool = true
    
    // MARK: - Lifecycle
    
    /// Called when the view appears; initializes the sprite and starts the update loop.
    private func setup() {
        guard let spriteNode = spriteNode else { return }
        
        // Initialize target values
        RandomizeSpriteEffect()
        
        // Start the update timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            if !isActive { return }
            
            guard let spriteNode = self.spriteNode else { return }
            
            let currentGray = spriteNode.color.grayscale
            let currentAlpha = spriteNode.color.a
            
            // Check if close enough to target
            if abs(currentGray - targetGrayScale) > 0.01 || abs(currentAlpha - targetAlpha) > 0.01 {
                // Smoothly interpolate toward target color
                let targetColor = SKColor(
                    red: CGFloat(targetGrayScale),
                    green: CGFloat(targetGrayScale),
                    blue: CGFloat(targetGrayScale),
                    alpha: CGFloat(targetAlpha)
                )
                
                let interpolatedColor = SKColor(
                    red: CGFloat(currentGray) + (CGFloat(targetGrayScale) - CGFloat(currentGray)) * CGFloat(transitionSpeed * 1.0 / 60.0),
                    green: CGFloat(currentGray) + (CGFloat(targetGrayScale) - CGFloat(currentGray)) * CGFloat(transitionSpeed * 1.0 / 60.0),
                    blue: CGFloat(currentGray) + (CGFloat(targetGrayScale) - CGFloat(currentGray)) * CGFloat(transitionSpeed * 1.0 / 60.0),
                    alpha: CGFloat(currentAlpha) + (CGFloat(targetAlpha) - CGFloat(currentAlpha)) * CGFloat(transitionSpeed * 1.0 / 60.0)
                )
                
                spriteNode.color = interpolatedColor
            } else {
                // Reached target, generate new one
                RandomizeSpriteEffect()
            }
        }
    }
    
    /// Called when the view disappears; stops the timer.
    private func cleanup() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Methods
    
    /// Randomizes the target grayscale and alpha values within the defined ranges.
    private func RandomizeSpriteEffect() {
        targetGrayScale = Float.random(in: Double(minGrayScale)...Double(maxGrayScale))
        targetAlpha = Float.random(in: Double(minAlpha)...Double(maxAlpha))
    }
    
    // MARK: - Body
    
    var body: some View {
        // Use a wrapper that manages the SKView lifecycle
        GeometryReader { geometry in
            ZStack {
                // Create and manage the SKScene programmatically
                SpriteView(
                    scene: SKScene(),
                    onSetup: { skView in
                        // Create the sprite node here
                        let sprite = SKSpriteNode(color: .white, size: CGSize(width: 100, height: 100))
                        sprite.position = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        sprite.name = "randomSprite"
                        
                        // Add it to the scene
                        skView.scene?.addChild(sprite)
                        
                        // Store reference
                        self.spriteNode = sprite
                        
                        // Setup the effect
                        setup()
                    },
                    onCleanup: { _ in
                        cleanup()
                    }
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
                .onDisappear {
                    cleanup()
                }
            }
        }
        .onAppear {
            setup()
        }
    }
}

// MARK: - Helper Extensions

extension SKColor {
    /// Returns the grayscale value of the color (average of RGB components).
    var grayscale: Float {
        return Float((red + green + blue) / 3.0)
    }
}

// MARK: - SwiftUI View Wrapper

/// A SwiftUI wrapper around SKView that supports dynamic scene setup and cleanup.
struct SpriteView: UIViewRepresentable {
    let scene: SKScene
    let onSetup: (SKView) -> Void
    let onCleanup: (SKView) -> Void
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView(frame: .zero)
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
        skView.backgroundColor = .clear
        
        // Set up the scene
        skView.presentScene(scene)
        
        // Call setup callback
        onSetup(skView)
        
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // No-op ¡ª we handle setup/cleanup externally
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: SpriteView
        
        init(_ parent: SpriteView) {
            self.parent = parent
        }
        
        deinit {
            parent.onCleanup(parent.makeUIView(context: .init()))
        }
    }
}