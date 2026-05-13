import SwiftUI
import SpriteKit

// [Positive Transfer] This Swift migration preserves the core logic of the original Unity C# Bullet class:
// - Movement in a direction (up or down based on isMovingUp)
// - Collision detection with "Death" and "Brick" tags
// - Destruction upon collision
// - Use of Time.deltaTime for frame-independent movement
// - Rotation of the sprite to flip direction if not moving up

// [New Fact] In SwiftUI + SpriteKit, we use SKNode as the base node instead of MonoBehaviour.
// We'll create a BulletComponent to hold data and a BulletSystem to handle logic.

// MARK: - Component (Data)

struct BulletComponent {
    var speed: CGFloat = 5.0
    var isMovingUp: Bool = true
    var isActive: Bool = true
}

// MARK: - System (Logic)

class BulletSystem: ObservableObject {
    
    // MARK: - Properties
    
    private var bulletNode: SKNode
    private var component: BulletComponent
    private let scene: SKScene
    private var lastUpdateTime: TimeInterval = 0
    
    // MARK: - Lifecycle
    
    init(scene: SKScene, position: CGPoint, isMovingUp: Bool = true) {
        self.scene = scene
        self.component = BulletComponent(speed: 5.0, isMovingUp: isMovingUp)
        self.bulletNode = SKNode()
        
        // Set initial position
        bulletNode.position = position
        
        // Setup rotation based on direction
        if !isMovingUp {
            bulletNode.zRotation = .pi // Rotate 180 degrees
        }
        
        // Add to scene
        scene.addChild(bulletNode)
        
        // Initialize time tracking
        lastUpdateTime = Date().timeIntervalSinceReferenceDate()
    }
    
    // MARK: - Public Methods
    
    func update() {
        guard component.isActive else { return }
        
        let currentTime = Date().timeIntervalSinceReferenceDate()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        move(deltaTime: deltaTime)
        checkCollisions()
    }
    
    // MARK: - Private Methods
    
    private func move(deltaTime: TimeInterval) {
        // Move upward or downward based on isMovingUp
        let direction: CGVector = component.isMovingUp ? CGVector(dx: 0, dy: 1) : CGVector(dx: 0, dy: -1)
        let distance = component.speed * CGFloat(deltaTime)
        bulletNode.position = bulletNode.position.offsetBy(dx: direction.dx * distance, dy: direction.dy * distance)
    }
    
    private func checkCollisions() {
        // Check for collisions with nodes tagged "Death" or "Brick"
        let allNodes = scene.children.compactMap { $0 as? SKNode }
        
        for node in allNodes {
            // Skip if it's this bullet
            if node === bulletNode { continue }
            
            // Check tag (we simulate tagging via user data)
            if let tag = node.userData?["tag"] as? String {
                switch tag {
                case "Death", "Brick":
                    destroy()
                    return
                default:
                    break
                }
            }
        }
    }
    
    private func destroy() {
        component.isActive = false
        bulletNode.removeFromParent()
    }
}

// MARK: - Extensions for convenience

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + dx, y: self.y + dy)
    }
}

// MARK: - Usage Example (in SwiftUI View)

struct BulletView: View {
    @StateObject private var bulletSystem: BulletSystem
    let startPosition: CGPoint
    let isMovingUp: Bool
    
    init(startPosition: CGPoint, isMovingUp: Bool = true) {
        _bulletSystem = StateObject(wrappedValue: BulletSystem(scene: SKScene(), position: startPosition, isMovingUp: isMovingUp))
        self.startPosition = startPosition
        self.isMovingUp = isMovingUp
    }
    
    var body: some View {
        SpriteView(scene: SKScene(), options: [.allowsTransparency])
            .onAppear {
                // Start the bullet system
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Simulate start delay if needed
                }
            }
            .onDisappear {
                bulletSystem.destroy()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // Re-enable if app comes back
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                // Pause or clean up if needed
            }
            .onTapGesture {
                // Optional: Handle tap gesture for iOS/visionOS
                // e.g., trigger bullet launch
            }
            .gesture(
                #if os(iOS)
                TapGesture(count: 1)
                    .onEnded { _ in
                        // Handle touch input for iOS
                    }
                #elseif os(visionOS)
                GestureRecognizer()
                    .onEnded { _ in
                        // Handle gaze or hand gesture in visionOS
                    }
                #else
                DragGesture()
                    .onChanged { value in
                        // Handle mouse drag on macOS
                    }
                #endif
            )
            .onReceive(Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()) { _ in
                bulletSystem.update()
            }
    }
}