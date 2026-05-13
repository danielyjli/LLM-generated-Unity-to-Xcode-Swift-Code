import SwiftUI
import SpriteKit
import AVFoundation

// MARK: - BrickComponent
struct BrickComponent: Component {
    var blood: Int = 1
    var bloodCounter: Int = 0
    var min: Int = 5
    var max: Int = 10
    var canvasspeed: Float = 1.0
    var item1Prefab: SKNode?
    var item2Prefab: SKNode?
    var item3Prefab: SKNode?
    var soundClip: AVAudioFile?
    var outputMixer: AVAudioMixerGroup?
    var textObject: SKNode?
    var textpoint: SKLabelNode?
    var gameManager: GameCounter?
}

// MARK: - BrickSystem
class BrickSystem: ObservableObject {
    @Published var bricks: [SKNode] = []
    private var audioEngine: AVAudioEngine = AVAudioEngine()
    
    func setupBrick(_ brick: SKNode, component: BrickComponent) {
        // Initialize audio source
        if let soundClip = component.soundClip {
            // Setup audio engine for playing sounds
        }
        
        // Set up canvas for text
        if let textObject = component.textObject,
           let textpoint = component.textpoint {
            textObject.isHidden = true
            textObject.zPosition = 10
            textpoint.fontSize = 24
            textpoint.fontColor = .white
            textpoint.position = CGPoint(x: 0, y: 20)
        }
    }
    
    func handleCollision(_ brick: SKNode, with other: SKNode, component: BrickComponent) {
        guard other.name == "Ball" || other.name == "Bullet" else { return }
        
        // Play sound
        if let soundClip = component.soundClip {
            // Play audio clip
        }
        
        component.bloodCounter += 1
        
        if component.bloodCounter > component.blood {
            // Remove collider
            if let physicsBody = brick.physicsBody {
                brick.physicsBody = nil
            }
            
            // Show text
            if let textObject = component.textObject {
                textObject.isHidden = false
                animateTextColor(component: component)
                moveText(component: component)
                spawnPoints(component: component)
            }
            
            // Fade out brick
            fadeOutBrick(brick, component: component)
        }
    }
    
    private func animateTextColor(component: BrickComponent) {
        guard let textpoint = component.textpoint else { return }
        
        let startColor = textpoint.textColor
        let endColor = UIColor.white
        let duration: TimeInterval = 0.7
        
        // Animate color change
        UIView.animate(withDuration: duration) {
            textpoint.textColor = endColor
        }
    }
    
    private func moveText(component: BrickComponent) {
        guard let textObject = component.textObject else { return }
        
        // Create repeating animation
        let moveAction = SKAction.moveBy(x: 0, y: CGFloat(component.canvasspeed), duration: 0.016)
        let repeatAction = SKAction.repeatForever(moveAction)
        textObject.run(repeatAction)
    }
    
    private func spawnPoints(component: BrickComponent) {
        guard let textpoint = component.textpoint,
              let gameManager = component.gameManager else { return }
        
        let randomValue = Int.random(in: component.min...component.max)
        textpoint.text = "+\(randomValue)"
        gameManager.addScore(randomValue)
    }
    
    private func fadeOutBrick(_ brick: SKNode, component: BrickComponent) {
        guard let spriteNode = brick as? SKSpriteNode else { return }
        
        let startColor = spriteNode.color
        let targetColor = UIColor(red: startColor.red, green: startColor.green, blue: startColor.blue, alpha: 0)
        let fadeTime: TimeInterval = 1.0
        
        // Fade out animation
        let fadeAction = SKAction.fadeOut(withDuration: fadeTime)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeAction, removeAction])
        
        brick.run(sequence) {
            // After fade out, call game manager
            component.gameManager?.brickDestroyed(brick)
            
            // Check if game over
            if !component.gameManager!.gameOver {
                self.onDestroy(brick, component: component)
            }
        }
    }
    
    private func onDestroy(_ brick: SKNode, component: BrickComponent) {
        let randomValue = Double.random(in: 0...1)
        
        if randomValue <= 0.03 {
            // Spawn item1
            if let item1Prefab = component.item1Prefab {
                // Instantiate item1Prefab at brick position
            }
        } else if randomValue <= 0.97 {
            // Spawn item2
            if let item2Prefab = component.item2Prefab {
                // Instantiate item2Prefab at brick position
            }
        } else if randomValue <= 0.09 {
            // Spawn item3
            if let item3Prefab = component.item3Prefab {
                // Instantiate item3Prefab at brick position
            }
        }
    }
}

// MARK: - GameCounter
class GameCounter: ObservableObject {
    @Published var score: Int = 0
    @Published var gameOver: Bool = false
    
    func addScore(_ points: Int) {
        score += points
    }
    
    func brickDestroyed(_ brick: SKNode) {
        // Handle brick destroyed event
    }
}