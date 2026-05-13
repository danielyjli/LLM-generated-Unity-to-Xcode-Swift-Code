import SwiftUI
import SpriteKit

// MARK: - Component
struct PropsComponent {
    var antiGravityForce: Float = 10.0  // 反重力场施加的力大小
    var isInAntiGravityField: Bool = false
}

// MARK: - System
class PropsSystem {
    private var component: PropsComponent
    private var physicsBody: SKPhysicsBody?
    
    init(antiGravityForce: Float = 10.0) {
        self.component = PropsComponent(antiGravityForce: antiGravityForce)
    }
    
    // [Positive Transfer] Direct equivalent to Unity's Start method
    func setup(with physicsBody: SKPhysicsBody) {
        self.physicsBody = physicsBody
    }
    
    // [Positive Transfer] FixedUpdate equivalent using SpriteKit's physics simulation
    func fixedUpdate() {
        guard let physicsBody = physicsBody, component.isInAntiGravityField else { return }
        
        // 反向施加持续向上的力
        let forceVector = CGVector(dx: 0, dy: CGFloat(component.antiGravityForce))
        physicsBody.applyForce(forceVector)
    }
    
    // [Positive Transfer] Collision handling with SpriteKit physics contacts
    func handleContact(with other: SKNode, didBegin: Bool) {
        if other.name == "AntiGravityField" {
            component.isInAntiGravityField = didBegin
        }
        
        if didBegin && (other.name == "Death" || other.name == "Board") {
            // TODO [Migrate]: Destroy game object equivalent
            // In SpriteKit, we would typically remove the node from parent
            other.removeFromParent()
        }
    }
}

// MARK: - SwiftUI View Wrapper
struct PropsView: View {
    @StateObject private var propsSystem = PropsSystem()
    @State private var scene: SKScene = {
        let scene = SKScene(size: CGSize(width: 300, height: 300))
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        return scene
    }()
    
    var body: some View {
        SpriteView(scene: scene)
            .onAppear {
                setupPhysicsBody()
            }
            .gesture(
                // macOS implementation
                #if os(macOS)
                DragGesture(minimumDistance: 0)
                    .onEnded { _ in
                        // Handle mouse click equivalent
                    }
                #endif
            )
            .gesture(
                // iOS implementation
                #if os(iOS)
                TapGesture()
                    .onEnded { _ in
                        // Handle touch equivalent
                    }
                #endif
            )
            .gesture(
                // visionOS implementation
                #if os(visionOS)
                SpatialTapGesture()
                    .onEnded { _ in
                        // Handle gaze/hand gesture equivalent
                    }
                #endif
            )
    }
    
    private func setupPhysicsBody() {
        let physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
        physicsBody.affectedByGravity = true
        propsSystem.setup(with: physicsBody)
    }
}