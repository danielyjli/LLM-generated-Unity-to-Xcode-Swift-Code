import SwiftUI
import SpriteKit

// MARK: - Component (Data)
struct BulletComponent {
    var speed: Float = 5.0 // 子弹速度，可以在编辑器中设置
    var isMovingUp: Bool = true // 子弹是否向上移动
    var position: CGPoint = .zero
    var rotation: CGFloat = 0.0
    var isActive: Bool = true
}

// MARK: - System (Logic)
class BulletSystem: ObservableObject {
    @Published var component: BulletComponent
    
    // Collision categories
    private let deathCategory: UInt32 = 0x1 << 1
    private let brickCategory: UInt32 = 0x1 << 2
    private let bulletCategory: UInt32 = 0x1 << 0
    
    init(speed: Float = 5.0, isMovingUp: Bool = true, position: CGPoint = .zero) {
        self.component = BulletComponent(speed: speed, isMovingUp: isMovingUp, position: position)
        setup()
    }
    
    // [Positive Transfer]
    private func setup() {
        if !component.isMovingUp {
            component.rotation = .pi // 180 degrees in radians
        }
    }
    
    // [Positive Transfer]
    func update(deltaTime: TimeInterval) {
        move(deltaTime: deltaTime)
    }
    
    // [Positive Transfer]
    private func move(deltaTime: TimeInterval) {
        // 根据移动方向和速度进行移动
        let direction: CGFloat = component.isMovingUp ? 1 : -1
        let movement = direction * CGFloat(component.speed) * CGFloat(deltaTime)
        component.position.y += movement
    }
    
    // [Positive Transfer]
    func handleTriggerEnter(with category: UInt32) {
        if category == deathCategory && component.isActive {
            destroy()
        }
    }
    
    // [Positive Transfer]
    func handleCollisionEnter(with category: UInt32) {
        if category == brickCategory && component.isActive {
            destroy()
        }
    }
    
    private func destroy() {
        component.isActive = false
        // In a real implementation, you would remove this bullet from the game scene
    }
}

// MARK: - View Representation
struct BulletView: View {
    @ObservedObject var system: BulletSystem
    
    var body: some View {
        if system.component.isActive {
            Rectangle()
                .fill(Color.red)
                .frame(width: 5, height: 10)
                .rotationEffect(.radians(system.component.rotation))
                .position(system.component.position)
        }
    }
}

// MARK: - SpriteKit Implementation Alternative
class BulletNode: SKSpriteNode {
    var speed: Float = 5.0
    var isMovingUp: Bool = true
    
    private let deathCategory: UInt32 = 0x1 << 1
    private let brickCategory: UInt32 = 0x1 << 2
    
    init(speed: Float = 5.0, isMovingUp: Bool = true) {
        self.speed = speed
        self.isMovingUp = isMovingUp
        
        let texture = SKTexture(imageNamed: "bullet") // You would need to provide a bullet image
        super.init(texture: texture, color: .clear, size: texture.size())
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // [Positive Transfer]
    private func setup() {
        if !isMovingUp {
            zRotation = .pi // 180 degrees in radians
        }
        
        // Physics setup
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = 0x1 << 0 // Bullet category
        physicsBody?.contactTestBitMask = deathCategory | brickCategory
        physicsBody?.collisionBitMask = brickCategory
    }
    
    // [Positive Transfer]
    func update(deltaTime: TimeInterval) {
        move(deltaTime: deltaTime)
    }
    
    // [Positive Transfer]
    private func move(deltaTime: TimeInterval) {
        // 根据移动方向和速度进行移动
        let direction: CGFloat = isMovingUp ? 1 : -1
        let movement = direction * CGFloat(speed) * CGFloat(deltaTime)
        position.y += movement
    }
    
    // [Positive Transfer]
    func handleContact(with body: SKPhysicsBody) {
        if body.categoryBitMask == deathCategory {
            removeFromParent()
        } else if body.categoryBitMask == brickCategory {
            removeFromParent()
        }
    }
}