import SwiftUI
import SpriteKit

// MARK: - GameCounter Component (Data)
struct GameCounterData {
    var bricks: [SKNode] = []
    var score: Int = 0
    var time: TimeInterval = 0
    var gameWon: Bool = false
    var gameOver: Bool = false
    
    // Text references (simulated via SwiftUI views in the UI layer)
    var scoreText: String { "Score: \(score)" }
    var timeText: String { "Time: \(Int(time))" }
}

// MARK: - GameCounter System (Logic)
class GameCounterSystem: ObservableObject {
    @Published var data = GameCounterData()
    
    private var startTime: TimeInterval = 0
    private var timer: Timer?
    
    // MARK: - Lifecycle
    func start() {
        // Find all bricks with tag "Brick"
        data.bricks = SKNode.findNodes(withName: "Brick") // This is a placeholder; actual implementation depends on how nodes are structured
        
        data.score = 0
        data.time = 0
        data.gameWon = false
        data.gameOver = false
        
        startTime = CFAbsoluteTimeGetCurrent()
        
        // Start updating timer every frame
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            self.update()
        }
    }
    
    func update() {
        guard !data.gameWon && !data.gameOver else { return }
        
        let currentTime = CFAbsoluteTimeGetCurrent()
        data.time = currentTime - startTime
        
        // Update text labels via binding to SwiftUI
        objectWillChange.send()
    }
    
    // MARK: - Public Methods
    func addScore(_ randomScore: Int) {
        data.score += randomScore
        objectWillChange.send()
    }
    
    func brickDestroyed(_ brick: SKNode) {
        if let index = data.bricks.firstIndex(of: brick) {
            data.bricks.remove(at: index)
        }
        
        // Remove from scene
        brick.removeFromParent()
        
        if data.bricks.isEmpty {
            data.gameWon = true
            data.gameOver = true
            gameOver()
        }
    }
    
    func ballEnteredDeathZone() {
        guard !data.gameOver else { return }
        
        data.gameOver = true
        gameOver()
    }
    
    // MARK: - Private Helpers
    private func gameOver() {
        // Save game state using UserDefaults (equivalent to PlayerPrefs)
        UserDefaults.standard.set(data.score, forKey: "Score")
        UserDefaults.standard.set(data.time, forKey: "Time")
        UserDefaults.standard.set(data.gameWon ? 1 : 0, forKey: "GameWon")
        
        // Scene transition ¡ª simulate by triggering a navigation event in SwiftUI
        // In reality, this would trigger a view change in the app's main view hierarchy
        // e.g., NavigationView or AppRouter
        NotificationCenter.default.post(name: .gameOver, object: nil)
    }
}

// MARK: - Extensions for Node Finding (Placeholder)
extension SKNode {
    static func findNodes(withName name: String) -> [SKNode] {
        // This is a simplified simulation. In real use, you'd traverse the scene graph.
        // For example, in SpriteKit, you might do:
        // return scene?.childNode(withName: "//\(name)")?.children ?? []
        return [] // Placeholder
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let gameOver = Notification.Name("GameOverNotification")
}

// MARK: - SwiftUI View Integration Example
struct GameCounterView: View {
    @StateObject private var gameCounterSystem = GameCounterSystem()
    
    var body: some View {
        VStack {
            Text(gameCounterSystem.data.scoreText)
                .font(.headline)
            
            Text(gameCounterSystem.data.timeText)
                .font(.subheadline)
            
            // Add buttons or other UI elements as needed
        }
        .onAppear {
            gameCounterSystem.start()
        }
        .onReceive(NotificationCenter.default.publisher(for: .gameOver)) { _ in
            // Navigate to GameOverScene
            // This could be done via a NavigationView or custom router
            print("Game over! Transitioning to GameOverScene...")
        }
    }
}

// MARK: - Input Handling (Platform-Specific)
// macOS: Keyboard + Mouse (Gesture-based input)
// iOS: Touch gestures (tap, drag, long press)
// visionOS: Hand gestures or gaze input

// Example: Handle brick destruction via touch/gesture (iOS/visionOS)
extension GameCounterSystem {
    func handleTapOnBrick(_ brick: SKNode) {
        if !data.gameOver {
            brickDestroyed(brick)
        }
    }
    
    func handleLongPressOnBrick(_ brick: SKNode) {
        if !data.gameOver {
            brickDestroyed(brick)
        }
    }
}

// Note: Actual gesture handling would be implemented in the SpriteKit scene or SwiftUI view
// depending on platform and architecture.

// [Positive Transfer] - The core logic of scoring, timing, and win/loss detection is preserved.
// [Negative Transfer] - Unity's GameObject system and SceneManager are replaced with SwiftUI + SpriteKit
//   and notification-based scene transitions.
// [New Fact] - Swift uses `@StateObject`, `ObservableObject`, and `NotificationCenter` instead of MonoBehaviour lifecycle.