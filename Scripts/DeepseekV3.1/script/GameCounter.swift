import SwiftUI
import SpriteKit
import Combine

// MARK: - Component
struct GameCounterComponent {
    var bricks: [SKNode] = []
    var score: Int = 0
    var time: TimeInterval = 0
    var gameWon: Bool = false
    var gameOver: Bool = false
}

// MARK: - System
class GameCounterSystem: ObservableObject {
    @Published private(set) var component: GameCounterComponent
    private var lastUpdateTime: TimeInterval?
    private var cancellables = Set<AnyCancellable>()
    
    // TODO [Migrate]: Replace with SwiftUI Text equivalents
    var scoreText: String = "Score: 0"
    var timeText: String = "Time: 0"
    var scoreText1: String = ""
    var timeText1: String = ""
    
    init() {
        component = GameCounterComponent()
        setup()
    }
    
    private func setup() {
        // [Positive Transfer]: Initialization logic preserved
        component.bricks = findBricks()
        component.score = 0
        component.time = 0
        component.gameWon = false
        component.gameOver = false
    }
    
    private func findBricks() -> [SKNode] {
        // TODO [Migrate]: Replace with SpriteKit equivalent of FindGameObjectsWithTag
        // In SpriteKit, you would typically use childNode(withName:) or enumerateChildNodes
        return []
    }
    
    func update(currentTime: TimeInterval) {
        guard !component.gameWon && !component.gameOver else { return }
        
        let deltaTime: TimeInterval
        if let lastTime = lastUpdateTime {
            deltaTime = currentTime - lastTime
        } else {
            deltaTime = 0
        }
        lastUpdateTime = currentTime
        
        component.time += deltaTime
        timeText = "Time: \(Int(round(component.time)))"
        scoreText = "Score: \(component.score)"
    }
    
    func addScore(_ randomScore: Int) {
        // [Positive Transfer]: Score addition logic preserved
        component.score += randomScore
    }
    
    func brickDestroyed(_ brick: SKNode) {
        // [Positive Transfer]: Brick removal and destruction logic preserved
        component.bricks.removeAll { $0 === brick }
        brick.removeFromParent()
        
        if component.bricks.isEmpty {
            component.gameWon = true
            component.gameOver = true
            gameOver()
        }
    }
    
    func ballEnteredDeathZone() {
        // [Positive Transfer]: Death zone logic preserved
        guard !component.gameOver else { return }
        component.gameOver = true
        gameOver()
    }
    
    private func gameOver() {
        // [Positive Transfer]: Game over state management preserved
        // TODO [Migrate]: Replace PlayerPrefs with UserDefaults or @AppStorage
        UserDefaults.standard.set(component.score, forKey: "Score")
        UserDefaults.standard.set(component.time, forKey: "Time")
        UserDefaults.standard.set(component.gameWon, forKey: "GameWon")
        
        // TODO [Migrate]: Replace SceneManager with SwiftUI navigation
        // In SwiftUI, you would use NavigationStack or sheet presentation
        print("Game Over - Navigate to GameOverScene")
    }
}

// MARK: - SwiftUI View
struct GameCounterView: View {
    @StateObject private var system = GameCounterSystem()
    @State private var gameTime: TimeInterval = 0
    
    var body: some View {
        VStack {
            Text(system.scoreText)
                .font(.headline)
            Text(system.timeText)
                .font(.headline)
            
            // Game content would be rendered here
            GeometryReader { geometry in
                GameSceneView(system: system, size: geometry.size)
                    .onAppear {
                        setupGameTimer()
                    }
            }
        }
    }
    
    private func setupGameTimer() {
        Timer.publish(every: 1.0/60.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                gameTime += 1.0/60.0
                system.update(currentTime: gameTime)
            }
            .store(in: &system.cancellables)
    }
}

// MARK: - SpriteKit Scene
struct GameSceneView: UIViewRepresentable {
    let system: GameCounterSystem
    let size: CGSize
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.presentScene(makeScene())
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {}
    
    private func makeScene() -> SKScene {
        let scene = SKScene(size: size)
        scene.scaleMode = .aspectFill
        
        // Input handling for different platforms
        #if os(macOS)
        setupMacInput(for: scene)
        #elseif os(iOS)
        setupIOSInput(for: scene)
        #elseif os(visionOS)
        setupVisionOSInput(for: scene)
        #endif
        
        return scene
    }
    
    #if os(macOS)
    private func setupMacInput(for scene: SKScene) {
        // macOS: Keyboard and mouse input
        let clickGesture = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleClick))
        scene.view?.addGestureRecognizer(clickGesture)
    }
    #endif
    
    #if os(iOS)
    private func setupIOSInput(for scene: SKScene) {
        // iOS: Touch gestures
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        scene.view?.addGestureRecognizer(tapGesture)
    }
    #endif
    
    #if os(visionOS)
    private func setupVisionOSInput(for scene: SKScene) {
        // visionOS: Hand gestures or gaze input
        // TODO [Migrate]: Implement visionOS-specific gesture handling
    }
    #endif
}