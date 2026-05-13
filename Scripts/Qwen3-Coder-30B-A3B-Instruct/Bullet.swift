import SwiftUI
import SpriteKit

// MARK: - Component
struct BulletComponent: Component {
    var speed: Float = 5.0
    var isMovingUp: Bool = true
}

// MARK: - System
class BulletSystem: SKNode {
    var component: BulletComponent
    var scene: SKScene?
    
    init(component: BulletComponent) {
        self.component = component
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        // [Positive Transfer] Start equivalent - Initialize bullet rotation
        if !component.isMovingUp {
            self.zRotation = .pi // 180 degrees in radians
        }
    }
    
    // [Positive Transfer] Update equivalent - Per-frame update
    func update(deltaTime: TimeInterval) {
        move(deltaTime: deltaTime)
    }
    
    private func move(deltaTime: TimeInterval) {
        // [Positive Transfer] Move equivalent - Apply movement based on direction and speed
        let moveDirection: CGPoint = component.isMovingUp ? CGPoint(x: 0, y: 1) : CGPoint(x: 0, y: -1)
        let moveAmount = CGFloat(component.speed) * CGFloat(deltaTime)
        self.position += moveDirection * moveAmount
    }
    
    // [Positive Transfer] OnTriggerEnter2D equivalent
    func handleTriggerEnter(node: SKNode) {
        if node.name == "Death" {
            // [Positive Transfer] Destroy equivalent
            removeFromParent()
        }
    }
    
    // [Positive Transfer] OnCollisionEnter2D equivalent
    func handleCollisionEnter(node: SKNode) {
        if node.name == "Brick" {
            // [Positive Transfer] Destroy equivalent
            removeFromParent()
        }
    }
}