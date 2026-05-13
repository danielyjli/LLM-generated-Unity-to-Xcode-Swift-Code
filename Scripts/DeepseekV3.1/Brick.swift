import SwiftUI
import SpriteKit
import Combine
import AVFoundation

// MARK: - Component
struct BrickComponent {
    var soundClip: String
    var outputMixer: AVAudioMixerNode?
    var min: Int = 5
    var max: Int = 10
    var blood: Int = 1
    var canvasSpeed: Float = 1.0
    var item1Prefab: String?
    var item2Prefab: String?
    var item3Prefab: String?
    var bloodCounter: Int = 0
    var isDestroyed: Bool = false
}

// MARK: - System
class BrickSystem: SKScene {
    private var brickEntity: SKNode?
    private var brickComponent: BrickComponent
    private var gameManager: GameCounterSystem
    private var textObject: SKNode?
    private var textLabel: SKLabelNode?
    private var audioPlayer: AVAudioPlayer?
    private var spriteRenderer: SKSpriteNode?
    private var cancellables = Set<AnyCancellable>()
    
    init(brickComponent: BrickComponent, gameManager: GameCounterSystem, size: CGSize) {
        self.brickComponent = brickComponent
        self.gameManager = gameManager
        super.init(size: size)
        setupBrick()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBrick() {
        // [Positive Transfer] SpriteKit equivalent of SpriteRenderer
        spriteRenderer = SKSpriteNode(color: .white, size: CGSize(width: 50, height: 20))
        spriteRenderer?.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(spriteRenderer!)
        
        // [Positive Transfer] Setup audio
        setupAudio()
        
        // [Positive Transfer] Setup text object
        setupTextObject()
    }
    
    private func setupAudio() {
        guard let soundURL = Bundle.main.url(forResource: brickComponent.soundClip, withExtension: nil) else {
            print("Sound file not found: \(brickComponent.soundClip)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.volume = 1.2
            // TODO [Migrate]: AudioMixerGroup output assignment needs custom audio engine setup
        } catch {
            print("Failed to load sound: \(error)")
        }
    }
    
    private func setupTextObject() {
        // [Positive Transfer] Create text object with SKLabelNode instead of Canvas
        textObject = SKNode()
        textLabel = SKLabelNode(text: "")
        textLabel?.fontColor = .black
        textLabel?.fontSize = 12
        textLabel?.verticalAlignmentMode = .center
        textLabel?.horizontalAlignmentMode = .center
        
        textObject?.addChild(textLabel!)
        textObject?.isHidden = true
        addChild(textObject!)
    }
    
    override func didMove(to view: SKView) {
        // [Positive Transfer] SpriteKit scene setup equivalent to Start()
        textObject?.position = spriteRenderer?.position ?? .zero
    }
    
    // [Positive Transfer] Collision handling with physics bodies
    func didBegin(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        
        if (nodeA?.name == "Ball" || nodeA?.name == "Bullet" || 
            nodeB?.name == "Ball" || nodeB?.name == "Bullet") && 
           (nodeA == spriteRenderer || nodeB == spriteRenderer) {
            
            handleCollision()
        }
    }
    
    private func handleCollision() {
        audioPlayer?.play()
        brickComponent.bloodCounter += 1
        
        if brickComponent.bloodCounter > brickComponent.blood {
            // [Positive Transfer] Remove physics body instead of collider
            spriteRenderer?.physicsBody = nil
            
            textObject?.isHidden = false
            startChangeColorCoroutine()
            startMoveCoroutine()
            
            let randomNumber = Int.random(in: brickComponent.min...brickComponent.max)
            textLabel?.text = "+\(randomNumber)"
            gameManager.addScore(randomNumber)
            
            startFadeOut()
        }
    }
    
    private func startChangeColorCoroutine() {
        // [Positive Transfer] Swift async/await instead of coroutines
        Task { @MainActor in
            let startColor = textLabel?.fontColor ?? .black
            let endColor = SKColor.white
            let duration: TimeInterval = 0.7
            
            for time in stride(from: 0.0, to: duration, by: 0.016) {
                let t = time / duration
                let newColor = interpolateColor(from: startColor, to: endColor, t: Float(t))
                textLabel?.fontColor = newColor
                try? await Task.sleep(nanoseconds: 16_000_000) // ~60fps
            }
            textLabel?.fontColor = endColor
        }
    }
    
    private func startMoveCoroutine() {
        // [Positive Transfer] Swift async/await movement
        Task { @MainActor in
            while !brickComponent.isDestroyed {
                let newPosition = CGPoint(
                    x: textObject?.position.x ?? 0,
                    y: (textObject?.position.y ?? 0) + CGFloat(brickComponent.canvasSpeed) * 0.016
                )
                textObject?.position = newPosition
                try? await Task.sleep(nanoseconds: 16_000_000) // ~60fps
            }
        }
    }
    
    private func startFadeOut() {
        // [Positive Transfer] Async fade out
        Task { @MainActor in
            let startColor = spriteRenderer?.color ?? .white
            let targetColor = startColor.withAlphaComponent(0)
            let fadeTime: TimeInterval = 1.0
            var elapsedTime: TimeInterval = 0
            
            while elapsedTime < fadeTime {
                elapsedTime += 0.016
                let t = Float(elapsedTime / fadeTime)
                spriteRenderer?.color = interpolateColor(from: startColor, to: targetColor, t: t)
                try? await Task.sleep(nanoseconds: 16_000_000)
            }
            
            brickComponent.isDestroyed = true
            gameManager.brickDestroyed(spriteRenderer!)
            
            if !gameManager.gameOver {
                onDestroy()
            }
            
            spriteRenderer?.removeFromParent()
        }
    }
    
    private func onDestroy() {
        let randomValue = Float.random(in: 0...1)
        
        if randomValue <= 0.03, let item1 = brickComponent.item1Prefab {
            instantiateItem(named: item1, at: spriteRenderer?.position ?? .zero)
        } else if randomValue <= 0.06, let item2 = brickComponent.item2Prefab {
            instantiateItem(named: item2, at: spriteRenderer?.position ?? .zero)
        } else if randomValue <= 0.09, let item3 = brickComponent.item3Prefab {
            instantiateItem(named: item3, at: spriteRenderer?.position ?? .zero)
        }
    }
    
    private func instantiateItem(named: String, at position: CGPoint) {
        // [Positive Transfer] Create new sprite node for item
        let itemNode = SKSpriteNode(imageNamed: named)
        itemNode.position = position
        addChild(itemNode)
    }
    
    private func interpolateColor(from: SKColor, to: SKColor, t: Float) -> SKColor {
        let fromComponents = from.components
        let toComponents = to.components
        
        return SKColor(
            red: CGFloat(lerp(from: Float(fromComponents.red), to: Float(toComponents.red), t: t)),
            green: CGFloat(lerp(from: Float(fromComponents.green), to: Float(toComponents.green), t: t)),
            blue: CGFloat(lerp(from: Float(fromComponents.blue), to: Float(toComponents.blue), t: t)),
            alpha: CGFloat(lerp(from: Float(fromComponents.alpha), to: Float(toComponents.alpha), t: t))
        )
    }
    
    private func lerp(from: Float, to: Float, t: Float) -> Float {
        return from + (to - from) * t
    }
}

// MARK: - SKColor extension for component access
extension SKColor {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
}