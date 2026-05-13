import Foundation
import SpriteKit
import AVFoundation
import GameplayKit

@objc class Brick : GKComponent {
    private var spriteRenderer: SpriteComponent?
    private var audioSource: AVAudioPlayer?
    private var outputMixer: AVAudioMixerGroup?
    private var gameManager: GameCounter?
    private var blood = 1
    private var bloodcounter = 0
    private var textObject: GameObject?
    private var textpoint: Text?
    private var canvasspeed = 1.0
    
    // MARK: - Initialization
    override init() {
        super.init()
        // Initialize audio source if not already initialized
        if audioSource == nil {
            audioSource = AVAudioPlayer()
            audioSource.volume = 1.2
        }
    }
    
    // MARK: - Input Handling
    override func handleInput(_ events: [UIEvent]) {
        for event in events {
            if event.type == .touch {
                handleTouch(event)
            } else if event.type == .mouse {
                handleMouseInput(event)
            }
        }
    }
    
    private func handleTouch(_ event: UIEvent) {
        // Handle touch events for iOS
        let touch = event.touches?.first
        if touch?.type == .touchDrag {
            handleDrag(touch)
        } else if touch?.type == .touchAndHold {
            handleLongPress()
        }
    }
    
    private func handleMouseInput(_ event: UIEvent) {
        // Handle mouse and keyboard input for macOS
        if let mouse = event.mouse {
            if mouse.type == .mouseDown {
                handleMouseClick()
            } else if mouse.type == .mouseDrag {
                handleDrag(event)
            }
        }
    }
    
    // MARK: - Collision Handling
    override func didCollide(_ other: Collision2D) {
        if let otherComponent = other.component(ofType: Brick.self) {
            // Handle collision with other bricks
            return
        }
        
        if otherComponent.CompareTag("Ball") || otherComponent.CompareTag("Bullet") {
            audioSource?.play(soundClip)
            bloodcounter += 1
            
            if bloodcounter > blood {
                // Remove the collider if exists
                if let collider = self.component(ofType: Collider2D.self) {
                    Destroy(collider)
                }
                
                // Show text object
                textObject?.SetActive(true)
                
                // Start animations
                startTextAnimation()
                startMoveAnimation()
                
                // Add random score
                let ramdomNumber = Int(Random.value * (max - min + 1) + min)
                textpoint?.text = String(ramdomNumber)
                gameManager?.addScore(ramdomNumber)
                
                // Start fade out
                startFadeOut()
            }
        }
    }
    
    // MARK: - Text Animation
    private func startTextAnimation() {
        StartCoroutine(textColorChange())
    }
    
    private func textColorChange() -> Int {
        let startColor = textpoint?.color ?? UIColor.white
        let endColor = UIColor.white
        let duration = 0.7
        
        for time in 0..<Int(duration * 60) {
            let t = Float(time) / Float(duration * 60)
            let newColor = Color.Lerp(startColor, endColor, t)
            textpoint?.color = newColor
            if time == Int(duration * 60) - 1 {
                break
            }
            yield nil
        }
        textpoint?.color = endColor
        return 0
    }
    
    // MARK: - Movement Animation
    private func startMoveAnimation() {
        let animation = MovementAnimation()
        self.addComponent(animation)
    }
    
    private class MovementAnimation : GKComponent {
        var speed = 1.0
        
        override init() {
            super.init()
            self.speed = 1.0
        }
        
        override func update(_ deltaTime: Double) {
            let transform = self.component(ofType: TransformComponent.self)?.transform ?? Transform()
            let newPosition = transform.position + Vector3.up * speed * deltaTime
            transform.position = newPosition
        }
    }
    
    // MARK: - Fade Out
    private func startFadeOut() {
        let animation = FadeOutAnimation()
        self.addComponent(animation)
    }
    
    private class FadeOutAnimation : GKComponent {
        var targetColor: Color = Color.clear
        var startColor: Color
        
        override init(_ color: Color) {
            startColor = color
            targetColor = Color.clear
            super.init()
        }
        
        override func update(_ deltaTime: Double) {
            let elapsed = CGFloat(deltaTime)
            let progress = elapsed / 1.0
            let newColor = Color.Lerp(startColor, targetColor, progress)
            self.component(ofType: SpriteComponent.self)?.color = newColor
        }
        
        override func didTerminate() {
            gameManager?.brickDestroyed(self)
            if !gameManager?.gameOver ?? false {
                self.destroy()
            }
        }
    }
    
    // MARK: - Destruction
    override func destroy() {
        // Generate random item
        let randomValue = Random.value
        if randomValue <= 0.03 {
            instantiateItem1()
        } else if randomValue <= 1.0 {
            instantiateItem2()
        } else if randomValue <= 0.09 {
            instantiateItem3()
        }
    }
    
    private func instantiateItem1() {
        let item = Item1Prefab?.instantiate()
        item?.position = transform.position
        item?.transform?.position = transform.position
    }
    
    private func instantiateItem2() {
        let item = Item2Prefab?.instantiate()
        item?.position = transform.position
        item?.transform?.position = transform.position
    }
    
    private func instantiateItem3() {
        let item = Item3Prefab?.instantiate()
        item?.position = transform.position
        item?.transform?.position = transform.position
    }
}