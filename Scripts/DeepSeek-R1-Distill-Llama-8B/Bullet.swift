import Foundation
import SpriteKit
import UIKit

// [Positive Transfer]
// Migrated Bullet class to Swift with platform-specific input handling
// [New Fact]

// MARK: - Bullet System (Logic)
system class BulletSystem : GameSystem {
    // MARK: - Properties
    var bullet: BulletComponent?
    
    // MARK: - Initialization
    override func start() {
        ensureBulletComponent()
    }
    
    // MARK: - Update
    override func update(_ delta: Float) {
        bullet?.update()
    }
    
    // MARK: - Collision Handling
    override func onCollision(_ other: GameEntity) {
        if let bullet = bullet, let otherComponent = other.component(ofType: BulletComponent.self) {
            if otherComponent.isDeath {
                destroyBullet(bullet)
            }
        }
    }
    
    // MARK: - Trigger Handling
    override func onTriggerEnter(_ other: GameEntity) {
        if let bullet = bullet, let otherComponent = other.component(ofType: BulletComponent.self) {
            if otherComponent.isDeath {
                destroyBullet(bullet)
            }
        }
    }
    
    // MARK: - Bullet Destruction
    private func destroyBullet(_ bullet: BulletComponent) {
        bullet.destroy()
        bullet = nil
    }
    
    // MARK: - Bullet Component (Data)
    struct BulletComponent : GameComponent {
        // MARK: - Properties
        var speed = 5.0 // 子弹速度
        var isMovingUp = true // 子弹是否向上移动
        
        // MARK: - Initialization
        init() {
            super.init()
            // [Positive Transfer]
            // Initialize bullet movement and collision handling
            // [New Fact]
        }
        
        // MARK: - Setup
        override func setup() {
            super.setup()
            // [Positive Transfer]
            // Rotate bullet if not moving up
            if !isMovingUp {
                transform.rotation = .init(x: 180, y: 0, z: 0)
            }
            // [New Fact]
        }
        
        // MARK: - Update
        override func update() {
            move()
        }
        
        // MARK: - Movement Handling
        private func move() {
            // [Positive Transfer]
            // Handle bullet movement based on direction and speed
            // [New Fact]
            let direction = isMovingUp ? Vector3.up : Vector3.down
            transform.translate(by: direction * speed * Time.delta)
        }
        
        // MARK: - Collision Handling
        override func onCollision(_ collision: Collision) {
            if collision.contactPoint != nil {
                handleCollision()
            }
        }
        
        // MARK: - Trigger Handling
        override func onTriggerEnter(_ other: Entity) {
            if other.hasComponent(ofType: BulletComponent.self) {
                handleCollision()
            }
        }
        
        // MARK: - Collision Handling
        private func handleCollision() {
            if let deathComponent = scene?.component(ofType: DeathComponent.self) {
                destroy()
            }
            
            if let brickComponent = scene?.component(ofType: BrickComponent.self) {
                destroy()
            }
        }
        
        // MARK: - Destruction
        func destroy() {
            scene?.removeEntity(self)
        }
    }
}