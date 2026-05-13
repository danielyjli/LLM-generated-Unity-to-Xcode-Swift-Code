import SwiftUI
import SpriteKit
import GameplayKit

// Component (data)
class PropsComponent {
    var antiGravityForce: Float = 10.0 // 反重力场施加的力大小
    var isInAntiGravityField: Bool = false
    var physicsBody: SKPhysicsBody?
    
    init() {}
}

// System (logic)
class PropsSystem: GKComponent {
    var component: PropsComponent
    
    override init() {
        self.component = PropsComponent()
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // [Positive Transfer]
    // Start to init/setup
    func setup(with node: SKNode) {
        component.physicsBody = node.physicsBody
    }
    
    // [Positive Transfer]
    // FixedUpdate equivalent - called per frame for physics updates
    func fixedUpdate() {
        if component.isInAntiGravityField {
            // 反向施加持续向上的力
            // Apply continuous upward force
            if let physicsBody = component.physicsBody {
                let force = CGVector(dx: 0, dy: CGFloat(component.antiGravityForce))
                physicsBody.applyForce(force)
            }
        }
    }
    
    // [Positive Transfer]
    // OnTriggerEnter2D equivalent
    func onTriggerEnter(with other: SKNode) {
        if other.name == "AntiGravityField" {
            component.isInAntiGravityField = true
        }
        if other.name == "Death" {
            // TODO [Migrate] - Need to implement object destruction in Swift context
            // Destroy(gameObject);
        }
        if other.name == "Board" {
            // TODO [Migrate] - Need to implement object destruction in Swift context
            // Destroy(gameObject);
        }
    }
    
    // [Positive Transfer]
    // OnTriggerExit2D equivalent
    func onTriggerExit(with other: SKNode) {
        if other.name == "AntiGravityField" {
            component.isInAntiGravityField = false
        }
    }
}