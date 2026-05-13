import SwiftUI
import SpriteKit

// MARK: - Component: FollowMouseComponent (Data)
struct FollowMouseComponent {
    var ball: Ball?
    var shootEffectPrefab: SKSpriteNode? // Assuming this is a preloaded sprite or node
    var gameManager: GameCounter?
    var isLengthen = 0
    var isShooting = false
    var totalShootTime: Float = 0
    var isLengthening = false
    var currentLengthenTime: Float = 0
    var totalLengthenTime: Float = 0
    var lengthenTime: Float = 3
}

// MARK: - System: FollowMouseSystem (Logic)
class FollowMouseSystem: ObservableObject {
    
    // MARK: - Dependencies
    @Published var scene: SKScene?
    private var mainCamera: SKCameraNode?
    private var screenBounds: CGPoint = .zero
    private var objectWidth: CGFloat = 0
    
    // MARK: - State
    private var component: FollowMouseComponent
    
    // MARK: - Initialization
    init(component: FollowMouseComponent) {
        self.component = component
    }
    
    // MARK: - Lifecycle
    func start() {
        guard let scene = scene else { return }
        mainCamera = scene.camera
    }
    
    // MARK: - Update (Per-frame logic)
    func update(deltaTime: TimeInterval) {
        guard let camera = mainCamera, let scene = scene else { return }
        
        // Update screen bounds in world space
        let screenSize = CGSize(width: scene.frame.width, height: scene.frame.height)
        screenBounds = camera.convert(screenSize, to: nil)
        objectWidth = abs(transform.bounds.size.width / 2)
        
        // Get mouse/touch/gaze position in world coordinates
        let mousePosition = getMousePosition()
        if let position = mousePosition {
            var newPosition = position
            newPosition.y = transform.position.y // Lock y-axis
            
            // Clamp x-position within screen bounds
            let leftBound = -screenBounds.x + objectWidth
            let rightBound = screenBounds.x - objectWidth
            newPosition.x = max(leftBound, min(rightBound, newPosition.x))
            
            transform.position = newPosition
        }
        
        // Check for ball existence
        if component.ball == nil {
            component.ball = findObjectOfType(Ball.self)
            if component.ball == nil {
                component.gameManager?.ballEnteredDeathZone()
            }
        }
    }
    
    // MARK: - Input Handling (Platform-specific)
    private func getMousePosition() -> CGPoint? {
        #if os(macOS)
        // macOS: Use mouse position with gesture recognizer
        guard let view = scene?.view else { return nil }
        let location = view.mouseLocationOutsideOfWindow
        return view.convert(location, to: nil)
        #elseif os(iOS)
        // iOS: Use touch gesture
        guard let touches = scene?.touches(for: .init())?.first else { return nil }
        return touches.location(in: scene)
        #elseif os(visionOS)
        // visionOS: Use hand/gaze input
        // TODO [Migrate]: Implement gaze or hand tracking using VisionOS SDK
        // For now, fallback to simulated mouse position
        return CGPoint(x: 0, y: 0)
        #else
        return nil
        #endif
    }
    
    // MARK: - Collision Handling
    func didCollide(with collision: SKPhysicsContact) {
        guard let bodyA = collision.bodyA.node as? SKNode,
              let bodyB = collision.bodyB.node as? SKNode else { return }
        
        let collidedNode = bodyA.isKind(of: SKNode.self) ? bodyA : bodyB
        
        if collidedNode.name == "SplitBall" {
            component.ball?.spawnSplitBall()
            collidedNode.removeFromParent()
        } else if collidedNode.name == "Shoot" {
            if !component.isShooting {
                startShooting(shootTime: 5.0)
            } else {
                component.totalShootTime += 5.0
            }
            collidedNode.removeFromParent()
        } else if collidedNode.name == "Lengthen" {
            collidedNode.removeFromParent()
            if !component.isLengthening {
                Task {
                    await lengthenBoardCoroutine(lengthenTime: component.lengthenTime)
                }
            } else {
                component.currentLengthenTime += component.lengthenTime
            }
        }
    }
    
    // MARK: - Coroutines (Simulated via async/await)
    private func lengthenBoardCoroutine(lengthenTime: Float) async {
        component.isLengthening = true
        component.currentLengthenTime = 0
        component.totalLengthenTime += lengthenTime
        
        // Scale up the board
        transform.scaleX *= 2
        transform.scaleY = transform.scaleY // Keep Y unchanged
        updateColliderSize(scaleFactor: 2)
        
        // Wait for duration
        try? await Task.sleep(for: .seconds(Double(lengthenTime)))
        
        // Reset after time expires
        transform.scaleX /= 2
        transform.scaleY = transform.scaleY
        updateColliderSize(scaleFactor: 0.5)
        
        component.isLengthening = false
    }
    
    // MARK: - Shooting Logic
    private func spawnShootEffect() {
        guard let effectPrefab = component.shootEffectPrefab,
              let scene = scene else { return }
        
        let effect = effectPrefab.copy() as! SKSpriteNode
        effect.position = transform.position
        effect.zPosition = 1
        scene.addChild(effect)
        
        // Optional: Remove after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            effect.removeFromParent()
        }
    }
    
    private func startShooting(shootTime: Float) {
        component.isShooting = true
        component.totalShootTime += shootTime
        Task {
            await shootContinuously()
        }
    }
    
    private func shootContinuously() async {
        var startTime = CFAbsoluteTimeGetCurrent()
        
        while component.totalShootTime > 0 {
            spawnShootEffect()
            try? await Task.sleep(for: .seconds(0.5)) // Shoot every 0.5 seconds
            
            let currentTime = CFAbsoluteTimeGetCurrent()
            let elapsedTime = Float(currentTime - startTime)
            component.totalShootTime -= elapsedTime
            startTime = currentTime
        }
        
        component.isShooting = false
    }
    
    // MARK: - Helper Methods
    private var transform: SKNode {
        return scene?.childNode(withName: "FollowMouse") ?? SKNode()
    }
    
    private func findObjectOfType<T: AnyObject>(_ type: T.Type) -> T? {
        guard let scene = scene else { return nil }
        return scene.childNode(withName: "Ball") as? T
    }
    
    private func updateColliderSize(scaleFactor: CGFloat) {
        // Assuming we have access to CapsuleCollider2D equivalent via physicsBody
        guard let physicsBody = transform.physicsBody else { return }
        physicsBody.size.width *= scaleFactor
        physicsBody.size.height = physicsBody.size.height // Keep height unchanged
    }
}