import SwiftUI
import SpriteKit

// MARK: - Brick Component (Data)
struct BrickComponent {
    var spriteRenderer: SKSpriteNode?
    var audioSource: SKAudioNode?
    var soundClip: SKAction?
    var outputMixer: AudioMixerGroup?
    var minScore = 5
    var maxScore = 10
    var gameManager: GameCounter?
    var blood = 1
    var bloodCounter = 0
    var textObject: SKNode?
    var textPointLabel: SKLabelNode?
    var canvasSpeed: CGFloat = 1.0
    var item1Prefab: SKNode?
    var item2Prefab: SKNode?
    var item3Prefab: SKNode?
}

// MARK: - Brick System (Logic)
class BrickSystem: SKNode, ObservableObject {
    
    @Published var component: BrickComponent
    
    init(component: BrickComponent) {
        self.component = component
        super.init()
        
        // Initialize components in Start-like setup
        setupComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupComponents() {
        // Setup sprite renderer
        if component.spriteRenderer == nil {
            let sprite = SKSpriteNode(color: .red, size: CGSize(width: 64, height: 32))
            sprite.name = "BrickSprite"
            component.spriteRenderer = sprite
            addChild(sprite)
        }
        
        // Setup audio source
        if component.audioSource == nil {
            let audioNode = SKAudioNode()
            component.audioSource = audioNode
            addChild(audioNode)
            
            // Set mixer group (SwiftUI/SpriteKit doesn't directly support AudioMixerGroup)
            // Instead, we use a workaround via AVAudioEngine or separate audio channels
            // TODO [Migrate]: Implement proper AudioMixerGroup logic using AVAudioEngine or similar
            // For now, just set volume
            audioSource?.volume = 1.2
        }
        
        // Setup sound clip (playable effect)
        if component.soundClip == nil {
            component.soundClip = SKAction.playSoundFileNamed("brick_hit.wav", waitForCompletion: false)
        }
        
        // Setup text object and label
        if component.textObject == nil {
            let textNode = SKNode()
            textNode.name = "ScoreText"
            textObject = textNode
            
            let label = SKLabelNode(text: "+0")
            label.fontSize = 24
            label.fontName = "Helvetica-Bold"
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            label.position = CGPoint(x: 0, y: 32)
            textNode.addChild(label)
            component.textPointLabel = label
            component.textObject = textNode
            addChild(textNode)
            
            // Set canvas to world space mode
            // In SpriteKit, we simulate this by positioning the node relative to world
            // No need for renderMode or worldCamera since SKNode is already in world space
            // [Positive Transfer] WorldSpace simulation achieved via SKNode placement
        }
        
        // Hide text initially
        component.textObject?.isHidden = true
        
        // Position the brick at origin
        position = .zero
    }
    
    // MARK: - Collision Handling
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.node ?? contact.bodyB.node
        
        guard let otherNode = other as? SKNode else { return }
        
        // Check tags: Ball or Bullet
        if otherNode.name == "Ball" || otherNode.name == "Bullet" {
            playSoundAndReact()
        }
    }
    
    private func playSoundAndReact() {
        guard let audioSource = component.audioSource,
              let soundClip = component.soundClip else { return }
        
        // Play sound
        audioSource.run(soundClip)
        
        // Increment blood counter
        component.bloodCounter += 1
        
        // Check if destroyed
        if component.bloodCounter > component.blood {
            // Remove collider
            physicsBody?.isDynamic = false
            physicsBody = nil
            
            // Show score text
            component.textObject?.isHidden = false
            
            // Run coroutines
            DispatchQueue.main.async {
                self.runColorChangeCoroutine()
                self.runMoveCoroutine()
                self.runFadeOutCoroutine()
            }
            
            // Generate random score
            let randomScore = Int.random(in: component.minScore...component.maxScore)
            component.textPointLabel?.text = "+\(randomScore)"
            component.gameManager?.addScore(randomScore)
        }
    }
    
    // MARK: - Coroutines (Simulated with async tasks)
    
    private func runColorChangeCoroutine() {
        guard let label = component.textPointLabel else { return }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let duration: CFTimeInterval = 0.7
        let startColor = label.color
        let endColor = UIColor.white
        
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime
            let t = min(elapsed / duration, 1.0)
            
            let r = startColor.red + (endColor.red - startColor.red) * CGFloat(t)
            let g = startColor.green + (endColor.green - startColor.green) * CGFloat(t)
            let b = startColor.blue + (endColor.blue - startColor.blue) * CGFloat(t)
            let a = startColor.alpha + (endColor.alpha - startColor.alpha) * CGFloat(t)
            
            label.color = UIColor(red: r, green: g, blue: b, alpha: a)
            
            if t >= 1.0 {
                label.color = endColor
                timer.invalidate()
            }
        }
    }
    
    private func runMoveCoroutine() {
        guard let textNode = component.textObject else { return }
        
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            let newPosition = textNode.position + CGVector(dx: 0, dy: component.canvasSpeed * 0.016)
            textNode.position = newPosition
            
            // Optional: Stop after some time
            // But Unity's coroutine runs forever unless stopped explicitly
            // So we keep it running unless needed to stop
        }
    }
    
    private func runFadeOutCoroutine() {
        guard let sprite = component.spriteRenderer else { return }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let duration: CFTimeInterval = 1.0
        let startColor = sprite.color
        let targetColor = UIColor(red: startColor.red, green: startColor.green, blue: startColor.blue, alpha: 0.0)
        
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime
            let t = min(elapsed / duration, 1.0)
            
            let r = startColor.red + (targetColor.red - startColor.red) * CGFloat(t)
            let g = startColor.green + (targetColor.green - startColor.green) * CGFloat(t)
            let b = startColor.blue + (targetColor.blue - startColor.blue) * CGFloat(t)
            let a = startColor.alpha + (targetColor.alpha - startColor.alpha) * CGFloat(t)
            
            sprite.color = UIColor(red: r, green: g, blue: b, alpha: a)
            
            if t >= 1.0 {
                // Notify game manager
                component.gameManager?.brickDestroyed(self)
                
                // Check if game is over
                if !component.gameManager?.isGameOver ?? false {
                    self.onDestroy()
                }
                
                // Destroy self
                self.removeFromParent()
                timer.invalidate()
            }
        }
    }
    
    // MARK: - OnDestroy Simulation
    private func onDestroy() {
        let randomValue = Double.random(in: 0...1)
        
        // Spawn items based on chance
        if randomValue <= 0.03 {
            spawnItem(from: component.item1Prefab, at: position)
        } else if randomValue <= 0.09 {
            spawnItem(from: component.item2Prefab, at: position)
        } else if randomValue <= 1.0 {
            spawnItem(from: component.item3Prefab, at: position)
        }
    }
    
    private func spawnItem(from prefab: SKNode?, at position: CGPoint) {
        guard let prefab = prefab else { return }
        
        let instance = prefab.copy() as? SKNode
        instance?.position = position
        instance?.name = "DroppedItem"
        addChild(instance!)
    }
}

// MARK: - GameCounter Protocol (for Score Management)
protocol GameCounter {
    func addScore(_ points: Int)
    func brickDestroyed(_ brick: BrickSystem)
    var gameOver: Bool { get }
}

// MARK: - Example Implementation of GameCounter (for testing)
class GameCounterImpl: GameCounter {
    var score = 0
    var gameOver = false
    
    func addScore(_ points: Int) {
        score += points
        print("Score: \(score)")
    }
    
    func brickDestroyed(_ brick: BrickSystem) {
        print("Brick destroyed.")
    }
}

// MARK: - SwiftUI View Integration
struct BrickView: View {
    @StateObject private var system: BrickSystem
    let component: BrickComponent
    
    init(component: BrickComponent) {
        _system = StateObject(wrappedValue: BrickSystem(component: component))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Use SpriteView to render the scene
                SpriteView(scene: system.scene, options: [.allowsTransparency])
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            // Add collision detection
            system.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 32))
            system.physicsBody?.categoryBitMask = 1 << 0 // Brick category
            system.physicsBody?.contactTestBitMask = 1 << 1 | 1 << 2 // Ball or Bullet
            system.physicsBody?.collisionBitMask = 0
        }
        .onChange(of: system.component.bloodCounter) { newValue in
            // Trigger update if needed
        }
    }
}

// MARK: - Input Handling (Platform-Specific)
extension BrickSystem {
    // macOS: Keyboard & Mouse Gestures
    // iOS: Touch Gestures (Tap, Drag, Long Press)
    // visionOS: Hand Gestures or Gaze Input
    // [New Fact] Swift uses GestureRecognizers instead of Unity's OnCollisionEnter2D
    // We'll use SKNode's touch handling via gesture recognizers in SwiftUI wrapper
}