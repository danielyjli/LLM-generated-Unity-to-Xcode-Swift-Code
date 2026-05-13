import Foundation
import SpriteKit
import GameplayKit

public class FollowMouse: SKNode {
    private var mainCamera: Camera?
    private var screenBounds = CGSize()
    private var objectWidth = 0.0
    
    public var ball: Ball?
    public var shootEffectPrefab: SKSpriteNode?
    
    public var gameManager: GameManager {
        get { return GameManager.shared }
        set { }
    }
    
    private var isLengthen = 0
    
    private var isShooting = false
    private var totalShootTime = 0.0
    
    private var isLengthening = false
    private var currentLengthenTime = 0.0
    private var totalLengthenTime = 0.0
    private var lengthenTime = 3.0
    
    public init() {
        super.init()
        // Initialize any required components
        self.name = "FollowMouse"
    }
    
    public func Start() {
        mainCamera = Camera.main
    }
    
    public func Update(_ delta: Double) {
        screenBounds = mainCamera?.ScreenToWorldPoint(
            mainCamera!.screenRectadn¨ªReference?.size,
            from: transform.position,
            into: transform.parent?.position ?? transform.position,
            relativeTo: mainCamera!.transform.position) ?? screenBounds
        
        objectWidth = (transform as? SKSpriteNode)?.bounds.extents.width
        
        // Get mouse position
        let mousePosition = Input.mousePosition
        mousePosition = mainCamera!.ScreenToWorldPoint(mousePosition)
        mousePosition.z = 0
        
        // Lock y-axis position
        mousePosition.y = transform.position.y
        
        // Clamp x-position within screen bounds
        let minX = screenBounds.x * -1 + objectWidth
        let maxX = screenBounds.x - objectWidth
        mousePosition.x = mousePosition.x.clamp(minX, maxX)
        
        transform.position = mousePosition
        
        if ball == nil {
            let ball = GKComponentUtils.findComponent(ofType: Ball.self) ?? null
            ball?.OnBallDeath()
        }
    }
    
    public func OnTriggerEnter(_ other: SKNode) {
        // Handle different node types
        if other.name == "SplitBall" {
            if let ball = GKComponentUtils.findComponent(ofType: Ball.self) {
                ball.SpawnSplitBall()
                Destroy(other)
            }
        } else if other.name == "Shoot" {
            if !isShooting {
                StartShooting(5.0)
            } else {
                totalShootTime += 5.0
            }
            Destroy(other)
        } else if other.name == "Lengthen" {
            Destroy(other)
            if !isLengthening {
                StartCoroutine(LengthenBoardCoroutine(lengthenTime))
            } else {
                currentLengthenTime += lengthenTime
            }
        }
    }
    
    public func LengthenBoardCoroutine(_ lengthenTime: Double) -> GameTimer {
        isLengthening = true
        currentLengthenTime = 0
        totalLengthenTime += lengthenTime
        
        transform.localScale *= 2
        let collider = self as? SKComponent<SKCapsuleCollider>
        if let collider = collider {
            collider.size.width *= 2
        }
        
        return GameTimer(timer: Timer(duration: totalLengthenTime)) {
            isLengthening = false
            currentLengthenTime = 0
        }
    }
    
    public func SpawnShootEffect() {
        if let effect = shootEffectPrefab {
            let instance = SKComponentUtils.instantiateComponent(ofType: effect.type) ?? effect
            instance.position = transform.position
            addChild(instance)
        }
    }
    
    public func StartShooting(_ shootTime: Double) {
        isShooting = true
        totalShootTime += shootTime
        StartCoroutine(ShootContinuously())
    }
    
    public func ShootContinuously() -> GameTimer {
        let startTime = Time.time
        
        while totalShootTime > 0 {
            SpawnShootEffect()
            yield()
            
            let currentTime = Time.time
            let elapsedTime = currentTime - startTime
            totalShootTime -= elapsedTime
            startTime = currentTime
        }
        
        isShooting = false
    }
}