import SwiftUI
import SpriteKit
import Combine

// MARK: - Component
struct BallComponent {
    var antiGravityForce: CGFloat = 10.0
    var decelerationAmount: CGFloat = 5.0
    var initialSpeed: CGFloat = 2.0
    var minForce: CGFloat = 1.0
    var maxForce: CGFloat = 2.0
    var moveLeft: Bool = false
    var isInAntiGravityField: Bool = false
}

// MARK: - System
class BallSystem: SKScene {
    private var ballComponent = BallComponent()
    private var ballNode: SKShapeNode!
    private var physicsBody: SKPhysicsBody!
    private var cancellables = Set<AnyCancellable>()
    
    // [Positive Transfer] - Direct migration of initialization logic
    override func didMove(to view: SKView) {
        setupBall()
        applyInitialVelocity()
    }
    
    private func setupBall() {
        ballNode = SKShapeNode(circleOfRadius: 20)
        ballNode.fillColor = .white
        ballNode.strokeColor = .clear
        ballNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(ballNode)
        
        physicsBody = SKPhysicsBody(circleOfRadius: 20)
        physicsBody.affectedByGravity = true
        physicsBody.allowsRotation = false
        physicsBody.friction = 0
        physicsBody.restitution = 1
        physicsBody.linearDamping = 0
        ballNode.physicsBody = physicsBody
    }
    
    private func applyInitialVelocity() {
        // 随机生成一个角度
        let angle = CGFloat.random(in: 0..<360)
        
        // 将角度转换为向量
        let radians = angle * .pi / 180
        let direction = CGVector(dx: cos(radians), dy: sin(radians))
        
        // 设置初始速度并保持Y轴方向向下
        physicsBody.velocity = CGVector(dx: direction.dx * ballComponent.initialSpeed, 
                                        dy: direction.dy * ballComponent.initialSpeed)
    }
    
    // [Positive Transfer] - Direct migration of collision handling
    func didBegin(_ contact: SKPhysicsContact) {
        ballComponent.moveLeft = Bool.random()
        
        // 生成随机的力
        let force = CGFloat.random(in: ballComponent.minForce...ballComponent.maxForce)
        
        // 根据左右方向施加力
        let direction: CGFloat = ballComponent.moveLeft ? -1.0 : 1.0
        let impulseVector = CGVector(dx: direction * force, dy: 0)
        physicsBody.applyImpulse(impulseVector)
    }
    
    // [Positive Transfer] - Direct migration of fixed update logic
    override func update(_ currentTime: TimeInterval) {
        if ballComponent.isInAntiGravityField {
            // 反向施加持续向上的力
            let forceVector = CGVector(dx: 0, dy: ballComponent.antiGravityForce)
            physicsBody.applyForce(forceVector)
        }
    }
    
    // [Positive Transfer] - Direct migration of trigger enter logic
    func didBeginContactWithNode(_ node: SKNode) {
        switch node.name {
        case "AntiGravityField":
            ballComponent.isInAntiGravityField = true
            
        case "Deceleration":
            let currentVelocity = physicsBody.velocity
            let normalizedVelocity = CGVector(dx: currentVelocity.dx / sqrt(currentVelocity.dx * currentVelocity.dx + currentVelocity.dy * currentVelocity.dy),
                                            dy: currentVelocity.dy / sqrt(currentVelocity.dx * currentVelocity.dx + currentVelocity.dy * currentVelocity.dy))
            let decelerationVector = CGVector(dx: normalizedVelocity.dx * ballComponent.decelerationAmount,
                                             dy: normalizedVelocity.dy * ballComponent.decelerationAmount)
            physicsBody.velocity = CGVector(dx: currentVelocity.dx - decelerationVector.dx,
                                           dy: currentVelocity.dy - decelerationVector.dy)
            
        case "Death":
            ballNode.removeFromParent()
            
        default:
            break
        }
    }
    
    // [Positive Transfer] - Direct migration of trigger exit logic
    func didEndContactWithNode(_ node: SKNode) {
        if node.name == "AntiGravityField" {
            ballComponent.isInAntiGravityField = false
        }
    }
    
    // [Positive Transfer] - Direct migration of split ball spawning
    func spawnSplitBall(with prefab: SKNode) {
        // 创建分裂球的预设体
        let splitBall1 = prefab.copy() as! SKNode
        let splitBall2 = prefab.copy() as! SKNode
        
        splitBall1.position = ballNode.position
        splitBall2.position = ballNode.position
        
        addChild(splitBall1)
        addChild(splitBall2)
    }
}

// MARK: - SwiftUI View
struct BallView: View {
    @StateObject private var scene: BallSystem
    
    init() {
        let scene = BallSystem()
        scene.size = CGSize(width: 300, height: 400)
        scene.scaleMode = .fill
        _scene = StateObject(wrappedValue: scene)
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .frame(width: 300, height: 400)
            .ignoresSafeArea()
            
            // macOS input
            #if os(macOS)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        // Handle mouse input
                    }
            )
            #endif
            
            // iOS input
            #if os(iOS)
            .gesture(
                TapGesture()
                    .onEnded {
                        // Handle touch input
                    }
            )
            #endif
            
            // visionOS input
            #if os(visionOS)
            .gesture(
                SpatialTapGesture()
                    .onEnded { value in
                        // Handle gaze/hand input
                    }
            )
            #endif
    }
}