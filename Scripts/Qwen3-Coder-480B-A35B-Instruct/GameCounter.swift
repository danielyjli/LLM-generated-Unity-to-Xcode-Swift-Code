import SwiftUI
import SpriteKit
import Foundation

// MARK: - Component
class GameCounterComponent: ObservableObject {
    @Published var bricks: [UUID] = []
    @Published var score: Int = 0
    @Published var time: Float = 0.0
    @Published var gameWon: Bool = false
    @Published var gameOver: Bool = false
    
    // References to UI elements would be handled differently in SwiftUI
    // These are kept for conceptual mapping but won't be used directly
    var scoreText: String = ""
    var timeText: String = ""
    var scoreText1: String = ""
    var timeText1: String = ""
}

// MARK: - System
class GameCounterSystem {
    weak var component: GameCounterComponent?
    private var lastUpdateTime: CFTimeInterval = 0
    private var sceneTimer: Timer?
    
    init(component: GameCounterComponent) {
        self.component = component
        setupTimer()
    }
    
    deinit {
        sceneTimer?.invalidate()
    }
    
    private func setupTimer() {
        sceneTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            self.update()
        }
    }
    
    // [Positive Transfer]
    // Unity's Start method maps to initialization in Swift
    func start(brickIDs: [UUID]) {
        component?.bricks = brickIDs
        component?.score = 0
        component?.time = 0.0
        component?.gameWon = false
        component?.gameOver = false
    }
    
    // [Positive Transfer]
    // Unity's Update method maps to a timer-based update loop
    private func update() {
        guard let component = component else { return }
        
        if !component.gameWon && !component.gameOver {
            // Calculate delta time manually since we don't have Unity's Time.deltaTime
            let currentTime = CACurrentMediaTime()
            if lastUpdateTime == 0 {
                lastUpdateTime = currentTime
            }
            let deltaTime = Float(currentTime - lastUpdateTime)
            lastUpdateTime = currentTime
            
            component.time += deltaTime
            component.timeText = "Time: \(Int(round(component.time)))"
            component.scoreText = "Score: \(component.score)"
        }
    }
    
    // [Positive Transfer]
    // Method signature and functionality preserved
    func addScore(_ randomScore: Int) {
        component?.score += randomScore
    }
    
    // [Positive Transfer]
    // Core logic preserved with adaptation to Swift patterns
    func brickDestroyed(_ brickID: UUID) {
        guard let component = component else { return }
        
        component.bricks.removeAll { $0 == brickID }
        
        if component.bricks.isEmpty {
            component.gameWon = true
            component.gameOver = true
            gameOver()
        }
    }
    
    // [Positive Transfer]
    // Logic preserved with appropriate naming
    func ballEnteredDeathZone() {
        guard let component = component else { return }
        
        if !component.gameOver {
            component.gameOver = true
            gameOver()
        }
    }
    
    // [Positive Transfer]
    // Core functionality maintained with platform-appropriate implementation
    private func gameOver() {
        guard let component = component else { return }
        
        // Save win/loss state, score, and time information
        // Using UserDefaults as equivalent to PlayerPrefs
        UserDefaults.standard.set(component.score, forKey: "Score")
        UserDefaults.standard.set(component.time, forKey: "Time")
        UserDefaults.standard.set(component.gameWon ? 1 : 0, forKey: "GameWon")
        
        // Scene transition would be handled by SwiftUI navigation
        // This is a placeholder for where scene change logic would occur
        // TODO [Migrate]: Implement scene transition to GameOverScene
    }
}

// MARK: - SwiftUI View (for demonstration of how this would integrate)
struct GameCounterView: View {
    @StateObject private var component = GameCounterComponent()
    private let system: GameCounterSystem
    
    init() {
        let system = GameCounterSystem(component: component)
        self.system = system
    }
    
    var body: some View {
        VStack {
            Text(component.scoreText)
                .font(.headline)
            Text(component.timeText)
                .font(.headline)
            // Additional UI elements would go here
        }
        .onAppear {
            // Simulate finding bricks by tag
            // In a real implementation, this would connect to your game objects
            let mockBrickIDs = [UUID(), UUID(), UUID()] // Example brick IDs
            system.start(brickIDs: mockBrickIDs)
        }
    }
}