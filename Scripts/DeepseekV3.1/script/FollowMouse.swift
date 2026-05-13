import SwiftUI
import SpriteKit
import Combine

// MARK: - Component
struct FollowMouseComponent {
    var mainCamera: SKCameraNode?
    var screenBounds: CGRect = .zero
    var objectWidth: CGFloat = 0
    
    var ball: BallEntity?
    var shootEffectPrefab: SKSpriteNode?
    
    var gameManager: GameCounter?
    var isLengthen: Int = 0
    
    var isShooting: Bool = false
    var totalShootTime: TimeInterval = 0
    
    var isLengthening: Bool = false
    var currentLengthenTime: TimeInterval = 0
    var totalLengthenTime: TimeInterval = 0
    var lengthenTime: TimeInterval = 3
}

// MARK: - System
class FollowMouseSystem {
    private var component: FollowMouseComponent
    private var scene: SKScene
    private var cancellables = Set<AnyCancellable>()
    
    init(scene: SKScene, component: FollowMouseComponent) {
        self.scene = scene
        self.component = component
        setupInputHandlers()
    }
    
    private func setupInputHandlers() {
        // [New Fact] Platform-specific input handling
        #if os(macOS)
        setupMacOSInput()
        #elseif os(iOS)
        setupIOSInput()
        #elseif os(visionOS)
        setupVisionOSInput()
        #endif
    }
    
    #if os(macOS)
    private func setupMacOSInput() {
        // TODO [Migrate] macOS keyboard and mouse input through gestures
        let mouseDrag = DragGesture(minimumDistance: 0)
            .onChanged { value in
                self.handleMousePosition(value.location)
            }
        // Add gesture to scene view if available
    }
    #elseif os(iOS)
    private func setupIOSInput() {
        // TODO [Migrate] iOS touch gestures (tap, drag, long press)
        let dragGesture = DragGesture(minimumDistance: 0)
            .onChanged { value in
                self.handleTouchPosition(value.location)
            }
        // Add gesture to scene view
    }
    #elseif os(visionOS)
    private func setupVisionOSInput() {
        // TODO [Migrate] visionOS hand gestures or gaze input
        // This would require VisionOS-specific gesture recognition
    }
    #endif
    
    func update(currentTime: TimeInterval, for node: SKNode) {
        guard let camera = component.mainCamera else {
            component.mainCamera = scene.camera
            return
        }
        
        // [Positive Transfer] Screen bounds calculation
        let viewSize = scene.size
        let cameraPosition = camera.position
        component.screenBounds = CGRect(
            x: cameraPosition.x - viewSize.width/2,
            y: cameraPosition.y - viewSize.height/2,
            width: viewSize.width,
            height: viewSize.height
        )
        
        if let sprite = node as? SKSpriteNode {
            component.objectWidth = sprite.size.width / 2
        }
        
        // Input position handling depends on platform setup
        // Actual position update happens in gesture handlers
        
        if component.ball == nil {
            // [Positive Transfer] Find ball entity
            component.ball = scene.children.compactMap { $0 as? BallEntity }.first
            if component.ball == nil {
                component.gameManager?.ballEnteredDeathZone()
            }
        }
    }
    
    private func handleMousePosition(_ position: CGPoint) {
        updateNodePosition(position, for: scene)
    }
    
    private func handleTouchPosition(_ position: CGPoint) {
        updateNodePosition(position, for: scene)
    }
    
    private func updateNodePosition(_ inputPosition: CGPoint, for scene: SKScene) {
        guard let camera = component.mainCamera else { return }
        
        let convertedPosition = scene.convertPoint(fromView: inputPosition)
        var newPosition = convertedPosition
        newPosition.z = 0
        
        // [Positive Transfer] Lock y-axis and clamp x-position
        if let node = scene.childNode(withName: "followMouseNode") {
            newPosition.y = node.position.y
            newPosition.x = max(
                component.screenBounds.minX + component.objectWidth,
                min(component.screenBounds.maxX - component.objectWidth, newPosition.x)
            )
            node.position = newPosition
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact, node: SKNode) {
        let otherNode = contact.bodyA.node == node ? contact.bodyB.node : contact.bodyA.node
        
        guard let other = otherNode else { return }
        
        // [Positive Transfer] Collision handling
        if other.name == "SplitBall" {
            component.ball?.spawnSplitBall()
            other.removeFromParent()
        } else if other.name == "Shoot" {
            if !component.isShooting {
                startShooting(5.0)
            } else {
                component.totalShootTime += 5.0
            }
            other.removeFromParent()
        } else if other.name == "Lengthen" {
            other.removeFromParent()
            if !component.isLengthening {
                startLengthenBoardCoroutine(component.lengthenTime, for: node)
            } else {
                component.currentLengthenTime += component.lengthenTime
            }
        }
    }
    
    private func startLengthenBoardCoroutine(_ lengthenTime: TimeInterval, for node: SKNode) {
        component.isLengthening = true
        component.currentLengthenTime = 0
        component.totalLengthenTime += lengthenTime
        
        // [Positive Transfer] Scale board and collider
        node.xScale *= 2
        if let physicsBody = node.physicsBody as? SKPhysicsBody {
            // Adjust physics body size if needed
        }
        
        // TODO [Migrate] Coroutine implementation using Combine
        Timer.publish(every: lengthenTime, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.component.currentLengthenTime != 0 {
                    self.component.currentLengthenTime = 0
                    return
                }
                
                // [Positive Transfer] Restore original scale
                node.xScale /= 2
                if let physicsBody = node.physicsBody as? SKPhysicsBody {
                    // Restore physics body size
                }
                
                self.component.isLengthening = false
            }
            .store(in: &cancellables)
    }
    
    private func spawnShootEffect(at position: CGPoint) {
        guard let effectPrefab = component.shootEffectPrefab?.copy() as? SKSpriteNode else { return }
        effectPrefab.position = position
        scene.addChild(effectPrefab)
    }
    
    private func startShooting(_ shootTime: TimeInterval) {
        component.isShooting = true
        component.totalShootTime += shootTime
        startShootContinuously()
    }
    
    private func startShootContinuously() {
        var startTime = Date().timeIntervalSince1970
        
        Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.component.totalShootTime <= 0 {
                    self.component.isShooting = false
                    return
                }
                
                if let node = self.scene.childNode(withName: "followMouseNode") {
                    self.spawnShootEffect(at: node.position)
                }
                
                let currentTime = Date().timeIntervalSince1970
                let elapsedTime = currentTime - startTime
                
                self.component.totalShootTime -= elapsedTime
                startTime = currentTime
            }
            .store(in: &cancellables)
    }
}

// MARK: - Supporting Entities
class BallEntity: SKNode {
    func spawnSplitBall() {
        // TODO [Migrate] Split ball implementation
    }
}

class GameCounter {
    func ballEnteredDeathZone() {
        // TODO [Migrate] Game counter implementation
    }
}