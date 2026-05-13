import SwiftUI
import SpriteKit
import GameController

// MARK: - Component (Data)
class BallComponent {
    var antiGravityForce: Float = 10.0 // 反重力场施加的力大小
    var decelerationAmount: Float = 5.0 // 减速量
    var isInAntiGravityField: Bool = false
    var initialSpeed: Float = 2.0
    
    var minForce: Float = 1.0
    var maxForce: Float = 2.0
    var moveLeft: Bool = false
    
    var splitBallPrefab: SKNode? = nil
}

// MARK: - System (Logic)
class BallSystem {
    private var component: BallComponent
    private var node: SKNode
    private var physicsBody: SKPhysicsBody?
    
    init(component: BallComponent, node: SKNode) {
        self.component = component
        self.node = node
        self.physicsBody = node.physicsBody
        setup()
    }
    
    // [Positive Transfer]
    private func setup() {
        // 随机生成一个角度
        let angle = Float.random(in: 0...360)
        
        // 将角度转换为向量
        let radians = angle * .pi / 180
        let direction = CGVector(dx: cos(CGFloat(radians)), dy: sin(CGFloat(radians)))
        
        // 设置初始速度并保持Y轴方向向下
        physicsBody?.velocity = CGVector(
            dx: direction.dx * CGFloat(component.initialSpeed),
            dy: direction.dy * CGFloat(component.initialSpeed)
        )
    }
    
    // [Positive Transfer]
    func onCollisionEnter(contact: SKPhysicsContact) {
        component.moveLeft = Bool.random()
        
        // 生成随机的力
        let force = Float.random(in: component.minForce...component.maxForce)
        
        // 根据左右方向施加力
        let direction: Float = component.moveLeft ? -1.0 : 1.0
        physicsBody?.applyImpulse(CGVector(dx: CGFloat(direction * force), dy: 0))
    }
    
    // [Positive Transfer]
    func fixedUpdate() {
        if component.isInAntiGravityField {
            // 反向施加持续向上的力
            physicsBody?.applyForce(CGVector(dx: 0, dy: CGFloat(component.antiGravityForce)))
        }
    }
    
    // [Positive Transfer]
    func onTriggerEnter(other: SKNode) {
        if other.name == "AntiGravityField" {
            component.isInAntiGravityField = true
        }
        if other.name == "Deceleration" {
            let velocity = physicsBody?.velocity ?? CGVector.zero
            let normalizedVelocity = CGVector(
                dx: velocity.dx / CGFloat(sqrt(pow(velocity.dx, 2) + pow(velocity.dy, 2))),
                dy: velocity.dy / CGFloat(sqrt(pow(velocity.dx, 2) + pow(velocity.dy, 2)))
            )
            physicsBody?.velocity = CGVector(
                dx: velocity.dx - normalizedVelocity.dx * CGFloat(component.decelerationAmount),
                dy: velocity.dy - normalizedVelocity.dy * CGFloat(component.decelerationAmount)
            )
        }
        if other.name == "Death" {
            node.removeFromParent()
        }
    }
    
    // [Positive Transfer]
    func onTriggerExit(other: SKNode) {
        if other.name == "AntiGravityField" {
            component.isInAntiGravityField = false
        }
    }
    
    // [Positive Transfer]
    func spawnSplitBall() {
        // 创建分裂球的预设体
        // TODO [Migrate] - Instantiation logic needs to be handled by scene manager
        /*
        guard let splitBall1 = component.splitBallPrefab?.copy() as? SKNode,
              let splitBall2 = component.splitBallPrefab?.copy() as? SKNode else { return }
        
        splitBall1.position = node.position
        splitBall2.position = node.position
        
        node.parent?.addChild(splitBall1)
        node.parent?.addChild(splitBall2)
        */
    }
}

// MARK: - Platform-Specific Input Extensions

// macOS Input Implementation
#if os(macOS)
extension BallSystem {
    func handleMouseInput(location: CGPoint) {
        // Handle mouse input for macOS
    }
    
    func handleKeyboardInput(key: String) {
        // Handle keyboard input for macOS
    }
}
#endif

// iOS Input Implementation
#if os(iOS)
extension BallSystem {
    func handleTouchInput(touches: Set<UITouch>) {
        // Handle touch input for iOS
    }
    
    func handleGestureInput(gesture: UIGestureRecognizer) {
        // Handle gesture input for iOS
    }
}
#endif

// visionOS Input Implementation
#if os(visionOS)
extension BallSystem {
    func handleHandGesture(hand: HandAnchor) {
        // Handle hand gesture input for visionOS
    }
    
    func handleGazeInput(gaze: GazeAnchor) {
        // Handle gaze input for visionOS
    }
}
#endif