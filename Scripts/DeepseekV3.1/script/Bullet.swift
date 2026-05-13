import SwiftUI
import SpriteKit
import Combine

// MARK: - Component
struct BulletComponent {
    var speed: Float = 5.0
    var isMovingUp: Bool = true
    var entity: SKNode?
}

// MARK: - System
class BulletSystem {
    private var scene: SKScene?
    private var cancellables = Set<AnyCancellable>()
    
    func setup(with scene: SKScene) {
        self.scene = scene
    }
    
    func createBullet(at position: CGPoint, isMovingUp: Bool) -> SKNode {
        let bullet = SKShapeNode(circleOfRadius: 5)
        bullet.fillColor = .white
        bullet.strokeColor = .clear
        bullet.position = position
        bullet.name = "bullet"
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = 0x1 << 0
        bullet.physicsBody?.collisionBitMask = 0x1 << 1
        bullet.physicsBody?.contactTestBitMask = 0x1 << 1
        
        var component = BulletComponent(isMovingUp: isMovingUp)
        component.entity = bullet
        bullet.userData = ["component": component]
        
        if !isMovingUp {
            bullet.zRotation = .pi // Rotate 180 degrees
        }
        
        scene.addChild(bullet)
        return bullet
    }
    
    func update(_ currentTime: TimeInterval) {
        scene?.children.forEach { node in
            guard node.name == "bullet",
                  let userData = node.userData as? [String: Any],
                  var component = userData["component"] as? BulletComponent else { return }
            
            // Move bullet based on direction and speed
            let direction: CGFloat = component.isMovingUp ? 1.0 : -1.0
            let moveAmount = CGFloat(component.speed) * 0.016 // Approximate delta time
            node.position.y += direction * moveAmount
            
            // Update component and store back
            component.entity = node
            node.userData = ["component": component]
        }
    }
    
    func handleCollision(between bullet: SKNode, and other: SKNode) {
        guard bullet.name == "bullet" else { return }
        
        if other.name == "Death" || other.name == "Brick" {
            bullet.removeFromParent()
        }
    }
}

// MARK: - Platform-Specific Input Handlers
#if os(macOS)
struct MacInputHandler {
    static func setupBulletShooting(scene: SKScene, bulletSystem: BulletSystem) {
        let clickGesture = NSClickGestureRecognizer(target: nil, action: nil)
        scene.view?.addGestureRecognizer(clickGesture)
        
        NotificationCenter.default.publisher(for: .init("NSClickGesture"))
            .sink { _ in
                let bullet = bulletSystem.createBullet(at: CGPoint(x: scene.size.width/2, y: 50), 
                                                     isMovingUp: true)
                scene.addChild(bullet)
            }
            .store(in: &cancellables)
    }
}
#elseif os(iOS)
struct iOSInputHandler {
    static func setupBulletShooting(scene: SKScene, bulletSystem: BulletSystem) {
        let tapGesture = UITapGestureRecognizer(target: nil, action: nil)
        scene.view?.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.publisher(for: .init("UITapGesture"))
            .sink { _ in
                let bullet = bulletSystem.createBullet(at: CGPoint(x: scene.size.width/2, y: 50), 
                                                     isMovingUp: true)
                scene.addChild(bullet)
            }
            .store(in: &cancellables)
    }
}
#elseif os(visionOS)
struct VisionOSInputHandler {
    static func setupBulletShooting(scene: SKScene, bulletSystem: BulletSystem) {
        // visionOS uses hand gestures or gaze input
        // Placeholder for visionOS-specific gesture handling
        let timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
        timer
            .sink { _ in
                let bullet = bulletSystem.createBullet(at: CGPoint(x: scene.size.width/2, y: 50), 
                                                     isMovingUp: true)
                scene.addChild(bullet)
            }
            .store(in: &cancellables)
    }
}
#endif

// MARK: - SwiftUI View Integration
struct GameView: View {
    @StateObject private var scene = GameScene()
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
            .onAppear {
                scene.setupBulletSystem()
            }
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    private let bulletSystem = BulletSystem()
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setupBoundaries()
        bulletSystem.setup(with: self)
        
        // Setup platform-specific input
        #if os(macOS)
        MacInputHandler.setupBulletShooting(scene: self, bulletSystem: bulletSystem)
        #elseif os(iOS)
        iOSInputHandler.setupBulletShooting(scene: self, bulletSystem: bulletSystem)
        #elseif os(visionOS)
        VisionOSInputHandler.setupBulletShooting(scene: self, bulletSystem: bulletSystem)
        #endif
    }
    
    override func update(_ currentTime: TimeInterval) {
        bulletSystem.update(currentTime)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
        bulletSystem.handleCollision(between: nodeA, and: nodeB)
        bulletSystem.handleCollision(between: nodeB, and: nodeA)
    }
    
    private func setupBoundaries() {
        let screenBounds = CGRect(origin: .zero, size: size)
        let deathZone = SKNode()
        deathZone.physicsBody = SKPhysicsBody(edgeLoopFrom: screenBounds)
        deathZone.physicsBody?.isDynamic = false
        deathZone.name = "Death"
        addChild(deathZone)
    }
    
    func setupBulletSystem() {
        // Initial setup if needed
    }
}