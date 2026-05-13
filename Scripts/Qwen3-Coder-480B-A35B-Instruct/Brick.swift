import SwiftUI
import SpriteKit
import AVFoundation
import GameController

// MARK: - Component Data Structure
struct BrickComponent {
    var min: Int = 5
    var max: Int = 10
    var blood: Int = 1
    var bloodcounter: Int = 0
    var canvasspeed: Float = 1.0
    
    // Prefabs for items
    var item1Prefab: String = "Item1" // Using string identifiers instead of GameObject references
    var item2Prefab: String = "Item2"
    var item3Prefab: String = "Item3"
    
    // State variables
    var isTextActive: Bool = false
    var textColor: Color = .white
    var textPosition: CGPoint = .zero
    var spriteAlpha: Double = 1.0
    var scoreText: String = ""
}

// MARK: - System Logic
class BrickSystem: ObservableObject {
    @Published var component: BrickComponent
    private var audioPlayer: AVAudioPlayer?
    private var gameCounter: GameCounterSystem
    private var soundClipURL: URL?
    
    // Coroutines simulation
    private var colorChangeTask: Task<Void, Never>?
    private var moveTask: Task<Void, Never>?
    private var fadeOutTask: Task<Void, Never>?
    
    init(gameCounter: GameCounterSystem) {
        self.component = BrickComponent()
        self.gameCounter = gameCounter
        
        // Setup audio - assuming sound clip is bundled
        // TODO [Migrate] Audio setup needs actual sound file path
        self.soundClipURL = Bundle.main.url(forResource: "brick_sound", withExtension: "mp3")
    }
    
    // [Positive Transfer]
    func setup() {
        // Initialize component values
        component.textPosition = .zero
        
        // Setup audio player
        if let url = soundClipURL {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.volume = 1.2
            } catch {
                print("Failed to initialize audio player: \(error)")
            }
        }
        
        // In Unity, Canvas setup would happen here
        // In SwiftUI/SpriteKit, this is handled by view hierarchy
    }
    
    // [Positive Transfer]
    func onCollisionEnter(with tag: String) {
        if tag == "Ball" || tag == "Bullet" {
            // Play sound
            audioPlayer?.play()
            
            component.bloodcounter += 1
            
            if component.bloodcounter > component.blood {
                // Show text object
                component.isTextActive = true
                
                // Start coroutines
                startColorChangeCoroutine()
                startMoveCoroutine()
                
                // Generate random score
                let randomNumber = Int.random(in: component.min...component.max)
                component.scoreText = "+\(randomNumber)"
                gameCounter.addScore(randomNumber)
                
                startFadeOutCoroutine()
            }
        }
    }
    
    // [Positive Transfer]
    private func startColorChangeCoroutine() {
        colorChangeTask = Task {
            let startTime = Date()
            let duration: TimeInterval = 0.7
            let startColor = component.textColor
            let endColor = Color.white
            
            while Date().timeIntervalSince(startTime) < duration && !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(startTime)
                let t = elapsed / duration
                
                // Linear interpolation between colors
                // Simplified color interpolation
                component.textColor = interpolateColor(from: startColor, to: endColor, progress: t)
                
                // Frame rate control - await next frame
                do {
                    try await Task.sleep(nanoseconds: 16_666_666) // ~60 FPS
                } catch {
                    break
                }
            }
            
            if !Task.isCancelled {
                component.textColor = endColor
            }
        }
    }
    
    // [Positive Transfer]
    private func startMoveCoroutine() {
        moveTask = Task {
            while !Task.isCancelled {
                // Move text upward
                component.textPosition.y += CGFloat(component.canvasspeed * 0.016) // Assuming 60 FPS
                
                do {
                    try await Task.sleep(nanoseconds: 16_666_666) // ~60 FPS
                } catch {
                    break
                }
            }
        }
    }
    
    // [Positive Transfer]
    private func startFadeOutCoroutine() {
        fadeOutTask = Task {
            let startTime = Date()
            let fadeTime: TimeInterval = 1.0
            let startAlpha = component.spriteAlpha
            let targetAlpha: Double = 0.0
            
            while Date().timeIntervalSince(startTime) < fadeTime && !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(startTime)
                let progress = elapsed / fadeTime
                component.spriteAlpha = startAlpha + (targetAlpha - startAlpha) * progress
                
                do {
                    try await Task.sleep(nanoseconds: 16_666_666) // ~60 FPS
                } catch {
                    break
                }
            }
            
            if !Task.isCancelled {
                component.spriteAlpha = targetAlpha
                gameCounter.brickDestroyed()
                
                if !gameCounter.gameOver {
                    onDestroy()
                }
                
                // In a real implementation, we'd signal removal of this brick
            }
        }
    }
    
    // [Positive Transfer]
    private func onDestroy() {
        let randomValue = Float.random(in: 0...1)
        
        if randomValue <= 0.03 {
            // Instantiate item1
            // In real implementation, this would notify the game system to create an item
            print("Instantiate item1 at position")
        } else if randomValue <= 1.0 {
            // Instantiate item2
            print("Instantiate item2 at position")
        } else if randomValue <= 0.09 {
            // Instantiate item3
            print("Instantiate item3 at position")
        }
    }
    
    // Helper method for color interpolation
    private func interpolateColor(from start: Color, to end: Color, progress: Double) -> Color {
        // This is a simplified implementation
        // A full implementation would convert to RGB and interpolate each component
        return progress < 0.5 ? start : end
    }
    
    // Cleanup when brick is removed
    deinit {
        colorChangeTask?.cancel()
        moveTask?.cancel()
        fadeOutTask?.cancel()
    }
}

// MARK: - View Representation
struct BrickView: View {
    @ObservedObject var system: BrickSystem
    var position: CGPoint
    
    var body: some View {
        ZStack {
            // Brick sprite
            Rectangle()
                .fill(Color.red.opacity(system.component.spriteAlpha))
                .frame(width: 50, height: 25)
            
            // Score text that appears when hit
            if system.component.isTextActive {
                Text(system.component.scoreText)
                    .foregroundColor(system.component.textColor)
                    .position(system.component.textPosition)
            }
        }
        .position(position)
    }
}

// MARK: - Platform-Specific Input Handlers

// [New Fact] macOS input handler using mouse and keyboard
class MacOSBrickInputHandler {
    weak var brickSystem: BrickSystem?
    
    func handleMouseClick(at point: CGPoint) {
        // Check if click intersects with brick
        // Implementation depends on how collision detection is set up
        brickSystem?.onCollisionEnter(with: "Ball")
    }
    
    func handleKeyPress(_ key: KeyEquivalent) {
        // Handle keyboard input if needed
    }
}

// [New Fact] iOS input handler using touch gestures
class IOSBrickInputHandler: NSObject {
    weak var brickSystem: BrickSystem?
    
    func handleTap() {
        brickSystem?.onCollisionEnter(with: "Ball")
    }
    
    func handleDrag(from startPoint: CGPoint, to endPoint: CGPoint) {
        // Handle drag gesture if needed
    }
    
    func handleLongPress() {
        // Handle long press if needed
    }
}

// [New Fact] VisionOS input handler using hand gestures or gaze
class VisionOSBrickInputHandler: NSObject {
    weak var brickSystem: BrickSystem?
    
    func handleGazeSelection() {
        brickSystem?.onCollisionEnter(with: "Ball")
    }
    
    func handleHandGesture(type: String) {
        // Handle different hand gestures
        brickSystem?.onCollisionEnter(with: "Ball")
    }
}

// [New Fact] Game counter system equivalent
class GameCounterSystem: ObservableObject {
    @Published var score: Int = 0
    @Published var gameOver: Bool = false
    
    func addScore(_ points: Int) {
        score += points
    }
    
    func brickDestroyed() {
        // Handle brick destruction logic
    }
}

// Helper extension for color interpolation (simplified)
extension Color {
    func interpolate(to color: Color, fraction: Double) -> Color {
        return fraction < 0.5 ? self : color
    }
}