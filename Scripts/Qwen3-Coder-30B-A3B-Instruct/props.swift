import SwiftUI
import SpriteKit

// MARK: - Component Data
struct PropsComponent: Component {
    var antiGravityForce: Float = 10.0
    var isInAntiGravityField: Bool = false
}

// MARK: - System Logic
class PropsSystem: ObservableObject {
    @Published var components: [UUID: PropsComponent] = [:]
    @Published var physicsBodies: [UUID: SKPhysicsBody] = [:]
    
    func setupComponent(id: UUID, node: SKNode) {
        let component = PropsComponent()
        components[id] = component
        
        // Setup physics body if not exists
        if physicsBodies[id] == nil {
            let physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
            physicsBody.isDynamic = true
            physicsBody.allowsRotation = true
            physicsBodies[id] = physicsBody
            node.physicsBody = physicsBody
        }
    }
    
    func updateComponent(id: UUID, deltaTime: TimeInterval) {
        guard var component = components[id],
              let physicsBody = physicsBodies[id] else { return }
        
        if component.isInAntiGravityField {
            // Apply upward force to counteract gravity
            let force = CGVector(dx: 0, dy: CGFloat(component.antiGravityForce))
            physicsBody.applyForce(force)
        }
    }
    
    func handleTriggerEnter(id: UUID, otherTag: String, node: SKNode) {
        guard var component = components[id] else { return }
        
        switch otherTag {
        case "AntiGravityField":
            component.isInAntiGravityField = true
            components[id] = component
        case "Death", "Board":
            // Remove node from scene
            node.removeFromParent()
        default:
            break
        }
    }
    
    func handleTriggerExit(id: UUID, otherTag: String) {
        guard var component = components[id] else { return }
        
        if otherTag == "AntiGravityField" {
            component.isInAntiGravityField = false
            components[id] = component
        }
    }
}

// MARK: - View Representation
struct PropsView: SKNodeRepresentable {
    let id: UUID
    let system: PropsSystem
    
    func makeSKNode(context: Context) -> SKNode {
        let node = SKNode()
        node.name = "Props"
        
        // Create visual representation (simple rectangle for now)
        let shape = SKShapeNode(rect: CGRect(x: -20, y: -20, width: 40, height: 40))
        shape.fillColor = .blue
        shape.strokeColor = .clear
        node.addChild(shape)
        
        system.setupComponent(id: id, node: node)
        return node
    }
    
    func updateSKNode(_ node: SKNode, context: Context) {
        // Update position and rotation based on physics
        if let physicsBody = system.physicsBodies[id] {
            node.position = physicsBody.location
            node.zRotation = physicsBody.rotation
        }
    }
}

// MARK: - Platform-Specific Input Handling
#if os(macOS)
import AppKit

extension PropsSystem {
    func handleMouseInput(location: NSPoint, isPressed: Bool) {
        // Mouse input handling for macOS
        // Implementation would depend on specific game mechanics
    }
}
#endif

#if os(iOS)
import UIKit

extension PropsSystem {
    func handleTouchInput(location: CGPoint, phase: UITouch.Phase) {
        // Touch input handling for iOS
        // Implementation would depend on specific game mechanics
    }
}
#endif

#if os(visionOS)
import RealityKit

extension PropsSystem {
    func handleHandGesture(gesture: HandGesture) {
        // Hand gesture handling for visionOS
        // Implementation would depend on specific game mechanics
    }
    
    func handleGazeInput(location: CGPoint, isFocused: Bool) {
        // Gaze input handling for visionOS
        // Implementation would depend on specific game mechanics
    }
}
#endif

// MARK: - Component Protocol
protocol Component {
    var id: UUID { get set }
}

extension Component {
    var id: UUID {
        get { UUID() } // This should be managed by the system
        set {}
    }
}