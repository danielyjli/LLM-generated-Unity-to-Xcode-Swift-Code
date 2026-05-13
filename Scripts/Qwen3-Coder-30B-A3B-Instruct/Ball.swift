import SwiftUI
import SpriteKit

// MARK: - Ball Component (Data)
struct BallComponent {
    var antiGravityForce: Float = 10.0
    var decelerationAmount: Float = 5.0
    var initialSpeed: Float = 2.0
    var minForce: Float = 1.0
    var maxForce: Float = 2.0
    var isInAntiGravityField: Bool = false
    var moveLeft: Bool = false
    var splitBallPrefab: SKNode?
}

// MARK: - Ball System (Logic)
class BallSystem: SKNode {
    private var component: BallComponent
    private var rigidBody: SKPhysicsBody?
    
    init(component: BallComponent) {
        self.component = component
        super.init()
        
        // Setup physics body
        self.rigidBody = SKPhysicsBody(circleOfRadius: 10)
        self.rigidBody?.allowsRotation = false
        self.rigidBody?.affectedByGravity = true
        self.physicsBody = self.rigidBody
        
        // Set initial velocity
        let angle = Float.random(in: 0...360)
        let direction = CGPoint(x: cos(angle * .pi / 180), y: sin(angle * .pi / 180))
        self.rigidBody?.velocity = CGVector(dx: direction.x * CGFloat(component.initialSpeed), dy: direction.y * CGFloat(component.initialSpeed))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // [Positive Transfer] FixedUpdate equivalent
    func update() {
        if component.isInAntiGravityField {
            // Apply upward force continuously
            self.rigidBody?.applyForce(CGVector(dx: 0, dy: CGFloat(component.antiGravityForce)))
        }
    }
    
    // [Positive Transfer] OnCollisionEnter2D equivalent
    func handleCollision(with other: SKNode) {
        component.moveLeft = Bool.random()
        
        // Generate random force
        let force = Float.random(in: component.minForce...component.maxForce)
        
        // Apply force based on direction
        let direction: CGFloat = component.moveLeft ? -1.0 : 1.0
        self.rigidBody?.applyImpulse(CGVector(dx: direction * CGFloat(force), dy: 0))
    }
    
    // [Positive Transfer] OnTriggerEnter2D equivalent
    func handleTriggerEnter(with other: SKNode) {
        if other.name == "AntiGravityField" {
            component.isInAntiGravityField = true
        }
        if other.name == "Deceleration" {
            let currentVelocity = self.rigidBody!.velocity
            let normalizedVelocity = CGVector(dx: currentVelocity.dx != 0 ? currentVelocity.dx / abs(currentVelocity.dx) : 0,
                                             dy: currentVelocity.dy != 0 ? currentVelocity.dy / abs(currentVelocity.dy) : 0)
            self.rigidBody?.velocity = CGVector(dx: currentVelocity.dx - normalizedVelocity.dx * CGFloat(component.decelerationAmount),
                                               dy: currentVelocity.dy - normalizedVelocity.dy * CGFloat(component.decelerationAmount))
        }
        if other.name == "Death" {
            self.removeFromParent()
        }
    }
    
    // [Positive Transfer] OnTriggerExit2D equivalent
    func handleTriggerExit(with other: SKNode) {
        if other.name == "AntiGravityField" {
            component.isInAntiGravityField = false
        }
    }
    
    // [Positive Transfer] SpawnSplitBall method
    func spawnSplitBall() {
        // Create two new balls at same position
        guard let prefab = component.splitBallPrefab else { return }
        
        let splitBall1 = prefab.copy() as! SKNode
        splitBall1.position = self.position
        self.parent?.addChild(splitBall1)
        
        let splitBall2 = prefab.copy() as! SKNode
        splitBall2.position = self.position
        self.parent?.addChild(splitBall2)
    }
}