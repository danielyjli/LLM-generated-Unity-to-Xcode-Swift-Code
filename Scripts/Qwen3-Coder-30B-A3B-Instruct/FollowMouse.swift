import SwiftUI
import SpriteKit

// MARK: - Component Data
struct FollowMouseComponent: Component {
    var mainCamera: SKCameraNode?
    var screenBounds: CGPoint = .zero
    var objectWidth: CGFloat = 0
    
    var ball: Ball?
    var shootEffectPrefab: SKNode?
    
    var gameManager: GameCounter?
    var isLengthen: Int = 0
    
    var isShooting: Bool = false
    var totalShootTime: TimeInterval = 0
    
    var isLengthening: Bool = false
    var currentLengthenTime: TimeInterval = 0
    var totalLengthenTime: TimeInterval = 0
    var lengthenTime: TimeInterval = 3
    
    var lengthenCoroutineTask: Task<Void, Never>? = nil
    var shootCoroutineTask: Task<Void, Never>? = nil
}

// MARK: - System Logic
class FollowMouseSystem: ComponentSystem<FollowMouseComponent> {
    
    // MARK: - Lifecycle Methods
    
    override func setup() {
        guard let scene = scene else { return }
        component.mainCamera = scene.camera
    }
    
    override func update(deltaTime: TimeInterval) {
        guard let camera = component.mainCamera else { return }
        
        // Get screen bounds
        let screenSize = CGSize(width: scene!.size.width, height: scene!.size.height)
        let screenBounds = camera.convertPoint(fromView: CGPoint(x: screenSize.width, y: screenSize.height))
        component.screenBounds = screenBounds
        
        // Get object width
        let spriteNode = node as? SKSpriteNode
        component.objectWidth = spriteNode?.calculateAccumulatedFrame().width ?? 0
        
        // Get mouse position
        let mousePosition = getMousePosition()
        let worldPosition = camera.convertPoint(fromView: mousePosition)
        var newPosition = worldPosition
        newPosition.z = 0
        
        // Lock Y axis
        newPosition.y = node.position.y
        
        // Clamp X position
        let minX = -screenBounds.x + component.objectWidth
        let maxX = screenBounds.x - component.objectWidth
        newPosition.x = max(minX, min(maxX, newPosition.x))
        
        node.position = newPosition
        
        // Check if ball is null
        if component.ball == nil {
            component.ball = findObjectOfType(Ball.self)
            if component.ball == nil {
                component.gameManager?.ballEnteredDeathZone()
            }
        }
    }
    
    // MARK: - Collision Handling
    
    func onTriggerEnter2D(_ collision: SKNode) {
        switch collision.name {
        case "SplitBall":
            component.ball?.spawnSplitBall()
            collision.removeFromParent()
        case "Shoot":
            if !component.isShooting {
                startShooting(5)
            } else {
                component.totalShootTime += 5
            }
            collision.removeFromParent()
        case "Lengthen":
            collision.removeFromParent()
            if !component.isLengthening {
                startLengthenCoroutine(component.lengthenTime)
            } else {
                component.currentLengthenTime += component.lengthenTime
            }
        default:
            break
        }
    }
    
    // MARK: - Coroutine Methods
    
    func startLengthenCoroutine(_ lengthenTime: TimeInterval) {
        component.isLengthening = true
        component.currentLengthenTime = 0
        component.totalLengthenTime += lengthenTime
        
        // Scale up board
        let currentScale = node.xScale
        node.setScale(currentScale * 2)
        
        // Update collider size
        if let capsuleCollider = node.physicsBody?.categoryBitMask {
            // Note: This would require access to the physics body properties
        }
        
        component.lengthenCoroutineTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(component.totalLengthenTime * 1_000_000_000))
            
            while component.currentLengthenTime != 0 {
                try? await Task.sleep(nanoseconds: UInt64(component.totalLengthenTime * 1_000_000_000))
            }
            
            // Restore original size
            let currentScale = node.xScale
            node.setScale(currentScale / 2)
            
            if let capsuleCollider = node.physicsBody?.categoryBitMask {
                // Note: This would require access to the physics body properties
            }
            
            component.isLengthening = false
        }
    }
    
    func spawnShootEffect() {
        // Create shooting effect prefab
        if let effectPrefab = component.shootEffectPrefab {
            let effectNode = effectPrefab.copy() as! SKNode
            effectNode.position = node.position
            scene?.addChild(effectNode)
        }
    }
    
    func startShooting(_ shootTime: TimeInterval) {
        component.isShooting = true
        component.totalShootTime += shootTime
        startShootCoroutine()
    }
    
    func startShootCoroutine() {
        component.shootCoroutineTask = Task {
            var startTime = CFAbsoluteTimeGetCurrent()
            
            while component.totalShootTime > 0 {
                spawnShootEffect()
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                let currentTime = CFAbsoluteTimeGetCurrent()
                let elapsedTime = currentTime - startTime
                component.totalShootTime -= elapsedTime
                startTime = currentTime
            }
            
            component.isShooting = false
        }
    }
    
    // MARK: - Platform-Specific Input
    
    func getMousePosition() -> CGPoint {
        #if os(macOS)
        return NSEvent.mouseLocation
        #elseif os(iOS) || os(visionOS)
        // For iOS/visionOS, we'd typically use gesture recognizers
        // This is a placeholder implementation
        return CGPoint.zero
        #endif
    }
}

// MARK: - Helper Extensions
extension SKNode {
    func calculateAccumulatedFrame() -> CGRect {
        // Simplified calculation
        return CGRect(origin: position, size: size)
    }
}

// MARK: - Placeholder Classes (to be implemented based on actual game structure)
class Ball {
    func spawnSplitBall() {
        // Implementation depends on actual Ball class
    }
}

class GameCounter {
    func ballEnteredDeathZone() {
        // Implementation depends on actual GameCounter class
    }
}

protocol Component {
    // Base component protocol
}

class ComponentSystem<T: Component> {
    var component: T
    var node: SKNode
    var scene: SKScene?
    
    init(node: SKNode, component: T) {
        self.node = node
        self.component = component
        setup()
    }
    
    func setup() {}
    func update(deltaTime: TimeInterval) {}
}