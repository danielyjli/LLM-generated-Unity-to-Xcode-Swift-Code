import SwiftUI
import SpriteKit

// MARK: - Ball Component (Data)
struct BallComponent {
    var antiGravityForce: CGFloat = 10.0
    var decelerationAmount: CGFloat = 5.0
    var initialSpeed: CGFloat = 2.0
    var minForce: CGFloat = 1.0
    var maxForce: CGFloat = 2.0
    var splitBallPrefab: SKNode? // Reference to the prefab node (assumed to be a SKNode or similar)
}

// MARK: - Ball System (Logic)
class BallSystem: ObservableObject {
    @Published var position: CGPoint = .zero
    @Published var velocity: CGVector = .zero
    @Published var isInAntiGravityField: Bool = false
    
    private let physicsWorld: SKPhysicsWorld
    private let ballNode: SKSpriteNode
    private let component: BallComponent
    private var isMovingLeft: Bool = false
    private var rb: SKPhysicsBody
    
    init(
        scene: SKScene,
        component: BallComponent,
        splitBallPrefab: SKNode? = nil
    ) {
        self.component = component
        self.physicsWorld = scene.physicsWorld
        self.ballNode = SKSpriteNode(color: .blue, size: CGSize(width: 30, height: 30))
        self.splitBallPrefab = splitBallPrefab
        
        // Setup physics body
        self.rb = SKPhysicsBody(circleOfRadius: 15)
        self.rb.mass = 1.0
        self.rb.linearDamping = 0.1
        self.rb.friction = 0.3
        self.rb.restitution = 0.7
        self.rb.categoryBitMask = 1
        self.rb.collisionBitMask = 1
        self.rb.contactTestBitMask = 1
        
        self.ballNode.physicsBody = rb
        self.ballNode.position = .zero
        scene.addChild(ballNode)
        
        // Start logic
        start()
    }
    
    func start() {
        // Random angle and direction
        let angle = CGFloat.random(in: 0...360) * .pi / 180
        let direction = CGVector(dx: cos(angle), dy: sin(angle))
        
        // Normalize and apply initial speed
        let normalizedDirection = direction.normalized
        velocity = normalizedDirection * component.initialSpeed
        
        // Ensure Y-axis is downward (inverted screen space)
        if velocity.dy < 0 {
            velocity.dy *= -1
        }
        
        // Apply initial velocity
        rb.velocity = velocity
    }
    
    func update(deltaTime: TimeInterval) {
        // Apply anti-gravity force if inside field
        if isInAntiGravityField {
            let force = CGVector(dx: 0, dy: component.antiGravityForce)
            rb.apply(force: force, as: .force)
        }
        
        // Optional: handle continuous damping or other behaviors here
    }
    
    // MARK: - Collision Handling
    func didCollide(with other: SKNode) {
        // Determine left/right movement randomly
        isMovingLeft = Bool.random()
        
        // Generate random force between min and max
        let force = CGFloat.random(in: component.minForce...component.maxForce)
        let direction = isMovingLeft ? -1.0 : 1.0
        let impulse = CGVector(dx: direction * force, dy: 0)
        
        // Apply impulse
        rb.apply(force: impulse, as: .impulse)
    }
    
    func didEnter(trigger: SKNode) {
        if trigger.name == "AntiGravityField" {
            isInAntiGravityField = true
        } else if trigger.name == "Deceleration" {
            // Reduce velocity in direction of motion
            let direction = velocity.normalized
            let reduction = direction * component.decelerationAmount
            velocity -= reduction
            rb.velocity = velocity
        } else if trigger.name == "Death" {
            destroy()
        }
    }
    
    func didExit(trigger: SKNode) {
        if trigger.name == "AntiGravityField" {
            isInAntiGravityField = false
        }
    }
    
    func spawnSplitBalls() {
        guard let prefab = splitBallPrefab else { return }
        
        // Create two split balls at current position
        for _ in 0..<2 {
            let newBall = prefab.copy() as? SKNode
            newBall?.position = ballNode.position
            
            // Add physics body to the new ball
            if let newRB = newBall?.physicsBody {
                newRB.mass = 1.0
                newRB.linearDamping = 0.1
                newRB.friction = 0.3
                newRB.restitution = 0.7
                newRB.categoryBitMask = 1
                newRB.collisionBitMask = 1
                newRB.contactTestBitMask = 1
            }
            
            // Add to scene
            if let scene = ballNode.scene {
                scene.addChild(newBall!)
            }
        }
    }
    
    func destroy() {
        ballNode.removeFromParent()
    }
    
    // MARK: - Utility Extensions
    private extension CGVector {
        func normalized() -> CGVector {
            let length = hypot(dx, dy)
            if length == 0 { return .zero }
            return CGVector(dx: dx / length, dy: dy / length)
        }
    }
}