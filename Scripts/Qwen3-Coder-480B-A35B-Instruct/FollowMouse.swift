import SwiftUI
import SpriteKit
import GameController

// MARK: - Component Data Structure
struct FollowMouseComponent {
    var ball: Ball?
    var shootEffectPrefab: SKNode?
    var gameManager: GameCounter?
    var isLengthen: Int = 0
    
    var isShooting: Bool = false
    var totalShootTime: TimeInterval = 0.0
    
    var isLengthening: Bool = false
    var currentLengthenTime: TimeInterval = 0.0
    var totalLengthenTime: TimeInterval = 0.0
    var lengthenTime: TimeInterval = 3.0
    
    var screenBounds: CGPoint = .zero
    var objectWidth: CGFloat = 0.0
}

// MARK: - System Logic
class FollowMouseSystem {
    // Reference to the entity's component data
    private var component: FollowMouseComponent
    
    // Reference to the node being controlled
    private weak var node: SKNode?
    private weak var scene: SKScene?
    
    // Timer references for coroutines
    private var lengthenTimer: Timer?
    private var shootTimer: Timer?
    private var lastShootTime: TimeInterval = 0.0
    
    init(component: FollowMouseComponent, node: SKNode, scene: SKScene) {
        self.component = component
        self.node = node
        self.scene = scene
    }
    
    // [Positive Transfer]
    // Called when the system starts, similar to Unity's Start()
    func setup() {
        // In Unity this gets Camera.main, here we'll use the scene's camera
        // Camera handling is implicit in SpriteKit through the scene
        
        // Initialize bounds and width on first frame
        updateScreenBoundsAndWidth()
    }
    
    // [Positive Transfer]
    // Called every frame, similar to Unity's Update()
    func update(currentTime: TimeInterval) {
        guard let node = self.node else { return }
        
        updateScreenBoundsAndWidth()
        
        // Get mouse position (this will be handled by gesture recognizers in practice)
        // For now, we'll assume a method to get cursor position exists
        let mousePosition = getCursorPosition()
        
        // Lock y-axis and clamp x-axis to screen bounds
        var newPosition = mousePosition
        newPosition.y = node.position.y
        newPosition.x = max(
            -component.screenBounds.x + component.objectWidth,
            min(component.screenBounds.x - component.objectWidth, newPosition.x)
        )
        
        node.position = newPosition
        
        // Check for missing ball reference
        if component.ball == nil {
            // TODO: Implement FindObjectOfType equivalent for Ball
            // This would require a registry of game objects in your system
            // component.gameManager?.BallEnteredDeathZone()
        }
    }
    
    // [New Fact]
    // Helper method to calculate screen bounds and object width
    private func updateScreenBoundsAndWidth() {
        guard let scene = self.scene, let node = self.node else { return }
        
        // Calculate screen bounds (similar to Camera.ScreenToWorldPoint in Unity)
        let screenSize = scene.size
        component.screenBounds = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        
        // Get object width (assuming the node has a sprite component)
        if let spriteNode = node as? SKSpriteNode {
            component.objectWidth = spriteNode.size.width / 2
        }
    }
    
    // [New Fact]
    // Method to get cursor position based on platform
    private func getCursorPosition() -> CGPoint {
        #if os(macOS)
        // On macOS, we'd track mouse position through event monitoring
        // This is a simplified placeholder
        return CGPoint.zero
        #elseif os(iOS)
        // On iOS, this would come from touch gestures
        return CGPoint.zero
        #elseif os(visionOS)
        // On visionOS, this would come from gaze or hand tracking
        return CGPoint.zero
        #else
        return CGPoint.zero
        #endif
    }
    
    // [Positive Transfer]
    // Handle collision enter events, similar to Unity's OnTriggerEnter2D
    func onTriggerEnter(with other: SKNode) {
        // Tag checking would need to be implemented via categories or custom properties
        let tag = other.name ?? ""
        
        if tag == "SplitBall" {
            component.ball?.spawnSplitBall()
            other.removeFromParent()
        } else if tag == "Shoot" {
            if !component.isShooting {
                startShooting(shootTime: 5.0)
            } else {
                component.totalShootTime += 5.0
            }
            other.removeFromParent()
        } else if tag == "Lengthen" {
            other.removeFromParent()
            if !component.isLengthening {
                lengthenBoard(for: component.lengthenTime)
            } else {
                component.currentLengthenTime += component.lengthenTime
            }
        }
    }
    
    // [Negative Transfer]
    // Coroutine replacement using Timer-based approach
    private func lengthenBoard(for lengthenTime: TimeInterval) {
        guard let node = self.node else { return }
        
        component.isLengthening = true
        component.currentLengthenTime = 0
        component.totalLengthenTime += lengthenTime
        
        // Scale up the board
        let originalScale = node.xScale
        node.setScale(originalScale * 2)
        
        // Adjust physics body if it exists
        if let physicsBody = node.physicsBody {
            if let originalSize = physicsBody.node?.calculateAccumulatedFrame().size {
                physicsBody.size = CGSize(width: originalSize.width * 2, height: originalSize.height)
            }
        }
        
        // Schedule timer to revert changes
        lengthenTimer?.invalidate()
        lengthenTimer = Timer.scheduledTimer(withTimeInterval: component.totalLengthenTime, repeats: false) { _ in
            self.component.currentLengthenTime = 0
            
            // Revert scale
            node.setScale(originalScale)
            
            // Revert physics body size
            if let physicsBody = node.physicsBody {
                if let originalSize = physicsBody.node?.calculateAccumulatedFrame().size {
                    physicsBody.size = originalSize
                }
            }
            
            self.component.isLengthening = false
        }
    }
    
    // [Positive Transfer]
    // Spawn visual effect for shooting
    private func spawnShootEffect() {
        guard let scene = self.scene,
              let effectPrefab = component.shootEffectPrefab else { return }
        
        let effect = effectPrefab.copy() as! SKNode
        effect.position = node?.position ?? .zero
        scene.addChild(effect)
    }
    
    // [Positive Transfer]
    // Start shooting sequence
    private func startShooting(shootTime: TimeInterval) {
        component.isShooting = true
        component.totalShootTime += shootTime
        shootContinuously()
    }
    
    // [Negative Transfer]
    // Continuous shooting using Timer instead of coroutine
    private func shootContinuously() {
        lastShootTime = CACurrentMediaTime()
        
        shootTimer?.invalidate()
        shootTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.spawnShootEffect()
            
            let currentTime = CACurrentMediaTime()
            let elapsedTime = currentTime - self.lastShootTime
            self.component.totalShootTime -= elapsedTime
            self.lastShootTime = currentTime
            
            if self.component.totalShootTime <= 0 {
                self.component.isShooting = false
                self.shootTimer?.invalidate()
                self.shootTimer = nil
            }
        }
    }
    
    // Cleanup timers when system is destroyed
    deinit {
        lengthenTimer?.invalidate()
        shootTimer?.invalidate()
    }
}

// MARK: - Supporting Types (Placeholders)
// These would need to be properly implemented in your actual project

protocol Ball {
    func spawnSplitBall()
}

protocol GameCounter {
    func BallEnteredDeathZone()
}

// [New Fact]
// Platform-specific input handling would be implemented in the view layer:

#if os(macOS)
// Mouse tracking implementation for macOS
extension FollowMouseSystem {
    func handleMouseMove(location: CGPoint) {
        // Update node position based on mouse location
        // This would be called from your SpriteKit view's mouse event handlers
    }
}
#endif

#if os(iOS)
// Touch gesture implementation for iOS
extension FollowMouseSystem {
    func handleTouchMove(location: CGPoint) {
        // Update node position based on touch location
    }
}
#endif

#if os(visionOS)
// Gaze/hand tracking implementation for visionOS
extension FollowMouseSystem {
    func handleGazeMove(location: CGPoint) {
        // Update node position based on gaze or hand position
    }
}
#endif