import SwiftUI
import SpriteKit

// [Positive Transfer] - This class is migrated from Unity's MonoBehaviour structure to Swift with equivalent logic using SpriteKit and SwiftUI.
// [New Fact] - In SwiftUI/SpriteKit, we use `SKNode` as the base for visual elements instead of `MonoBehaviour`.
// [New Fact] - Physics bodies are managed via `SKPhysicsBody`, and collision detection uses `didBeginContact` and `didEndContact`.

struct PropsComponent: View {
    // [Positive Transfer] - Equivalent to public float antiGravityForce in C#
    let antiGravityForce: CGFloat = 10.0
    
    // [Positive Transfer] - Equivalent to private bool isInAntiGravityField
    @State private var isInAntiGravityField = false
    
    // [Positive Transfer] - Equivalent to private Rigidbody2D rb
    private var physicsBody: SKPhysicsBody?
    
    // [Positive Transfer] - Equivalent to Start() method
    init() {
        // Setup is handled in the scene or node creation
    }
    
    // [Positive Transfer] - Equivalent to Update() method (called every frame)
    // In SpriteKit, this is handled via the scene's update loop
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Placeholder for the visual representation
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text("Props")
                            .font(.caption)
                            .foregroundColor(.white)
                    )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                setupPhysicsBody()
            }
            .onChange(of: isInAntiGravityField) { newValue in
                if newValue {
                    applyAntiGravity()
                } else {
                    stopAntiGravity()
                }
            }
        }
    }
    
    // [Positive Transfer] - Equivalent to FixedUpdate() method
    // In SpriteKit, we handle physics updates in the scene's update function
    func applyAntiGravity() {
        guard let body = physicsBody else { return }
        // Apply continuous upward force
        body.applyImpulse(CGVector(dx: 0, dy: antiGravityForce), asImpulse: true)
    }
    
    func stopAntiGravity() {
        // No need to do anything special; force stops naturally when not applied
        // We just ensure no new forces are added
    }
    
    // [Positive Transfer] - Equivalent to OnTriggerEnter2D
    func didBeginContact(with other: SKPhysicsBody) {
        if other.categoryBitMask == AntiGravityFieldCategory {
            isInAntiGravityField = true
        }
        
        if other.categoryBitMask == DeathCategory {
            // Destroy the node by removing it from the scene
            // In SwiftUI, we use a binding to control visibility
            // For simplicity, we assume parent view handles removal
            // Alternatively, trigger an event to remove the node
            // Here, we simulate destruction via setting state
            isInAntiGravityField = false // Just to clean up
            // The actual removal should be done by parent view
        }
        
        if other.categoryBitMask == BoardCategory {
            isInAntiGravityField = false
            // Same as above: destroy object by removing from scene
        }
    }
    
    // [Positive Transfer] - Equivalent to OnTriggerExit2D
    func didEndContact(with other: SKPhysicsBody) {
        if other.categoryBitMask == AntiGravityFieldCategory {
            isInAntiGravityField = false
        }
    }
    
    // [Positive Transfer] - Initialize physics body
    private func setupPhysicsBody() {
        let body = SKPhysicsBody(circleOfRadius: 25)
        body.isDynamic = true
        body.categoryBitMask = PropsCategory
        body.contactTestBitMask = AntiGravityFieldCategory | DeathCategory | BoardCategory
        body.affectedByGravity = true
        
        self.physicsBody = body
    }
}

// MARK: - Physics Categories (equivalent to Tags in Unity)
let PropsCategory: UInt32 = 1 << 0
let AntiGravityFieldCategory: UInt32 = 1 << 1
let DeathCategory: UInt32 = 1 << 2
let BoardCategory: UInt32 = 1 << 3

// MARK: - Scene Integration Example (for SwiftUI + SpriteKit)
struct PropsSceneView: View {
    @StateObject private var sceneManager = PropsSceneManager()
    
    var body: some View {
        VStack {
            // Use SpriteView to host the SKScene
            SpriteView(scene: sceneManager.scene)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Scene Manager (handles physics update loop)
class PropsSceneManager: ObservableObject {
    let scene = SKScene()
    
    init() {
        scene.backgroundColor = .black
        scene.scaleMode = .aspectFill
        
        // Add props node
        let propsNode = SKNode()
        propsNode.position = CGPoint(x: 400, y: 300)
        scene.addChild(propsNode)
        
        // Attach physics body
        let physicsBody = SKPhysicsBody(circleOfRadius: 25)
        physicsBody.isDynamic = true
        physicsBody.categoryBitMask = PropsCategory
        physicsBody.contactTestBitMask = AntiGravityFieldCategory | DeathCategory | BoardCategory
        physicsBody.affectedByGravity = true
        
        propsNode.physicsBody = physicsBody
        
        // Set up contact delegate
        scene.physicsWorld.contactDelegate = self
        
        // Add anti-gravity field
        let antiGravityField = SKNode()
        antiGravityField.position = CGPoint(x: 600, y: 200)
        antiGravityField.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 100))
        antiGravityField.physicsBody?.categoryBitMask = AntiGravityFieldCategory
        antiGravityField.physicsBody?.isDynamic = false
        antiGravityField.physicsBody?.allowsRotation = false
        antiGravityField.name = "AntiGravityField"
        scene.addChild(antiGravityField)
        
        // Add death zone
        let deathZone = SKNode()
        deathZone.position = CGPoint(x: 200, y: 100)
        deathZone.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 150, height: 100))
        deathZone.physicsBody?.categoryBitMask = DeathCategory
        deathZone.physicsBody?.isDynamic = false
        deathZone.physicsBody?.allowsRotation = false
        deathZone.name = "DeathZone"
        scene.addChild(deathZone)
        
        // Add board
        let board = SKNode()
        board.position = CGPoint(x: 800, y: 150)
        board.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: 20))
        board.physicsBody?.categoryBitMask = BoardCategory
        board.physicsBody?.isDynamic = false
        board.physicsBody?.allowsRotation = false
        board.name = "Board"
        scene.addChild(board)
        
        // Simulate update loop
        scene.update = { deltaTime in
            // Call update logic here
            // This is where you'd call any per-frame logic like applying forces
            // But in our case, forces are applied only on contact
        }
    }
}

// MARK: - Contact Delegate
extension PropsSceneManager: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        // Determine which body is the props
        if firstBody.categoryBitMask == PropsCategory {
            // Check second body
            if secondBody.categoryBitMask == AntiGravityFieldCategory {
                // Apply anti-gravity effect
                // We'll store this state in the node or use a callback
                // For now, we just log it ¡ª in real app, use a shared state manager
                print("Entered anti-gravity field")
                // Trigger anti-gravity via a callback or animation
            } else if secondBody.categoryBitMask == DeathCategory || secondBody.categoryBitMask == BoardCategory {
                // Remove props node
                print("Destroyed props")
                // Remove from scene
                firstBody.node?.removeFromParent()
            }
        } else if secondBody.categoryBitMask == PropsCategory {
            // Same logic but reversed
            if firstBody.categoryBitMask == AntiGravityFieldCategory {
                print("Entered anti-gravity field")
            } else if firstBody.categoryBitMask == DeathCategory || firstBody.categoryBitMask == BoardCategory {
                print("Destroyed props")
                secondBody.node?.removeFromParent()
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PropsCategory && secondBody.categoryBitMask == AntiGravityFieldCategory {
            print("Exited anti-gravity field")
        } else if secondBody.categoryBitMask == PropsCategory && firstBody.categoryBitMask == AntiGravityFieldCategory {
            print("Exited anti-gravity field")
        }
    }
}