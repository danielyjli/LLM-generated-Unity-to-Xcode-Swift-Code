import SwiftUI
import SpriteKit

// MARK: - GameOverManager Component (Data)
struct GameOverManagerComponent {
    var resultText: String = ""
    var scoreText: String = ""
    var timeText: String = ""
    var resultText1: String = ""
    var scoreText1: String = ""
    var timeText1: String = ""
    var mirrortext: String = ""
    var soundClip1: SoundAsset?
    var soundClip2: SoundAsset?
    var tagsToDestroy: [String] = []
    var outputMixer: AudioMixerGroup?
}

// MARK: - GameOverManager System (Logic)
class GameOverManagerSystem: ObservableObject {
    @Published var component: GameOverManagerComponent
    
    private var audioSource: SKAudioNode?
    
    // MARK: - Initialization
    init(component: GameOverManagerComponent) {
        self.component = component
    }
    
    // MARK: - Lifecycle Methods
    func start() {
        destroyGeneratedItems()
        
        let gameWon = UserDefaults.standard.bool(forKey: "GameWon")
        let score = UserDefaults.standard.integer(forKey: "Score")
        let time = UserDefaults.standard.float(forKey: "Time")
        
        // Initialize audio source
        audioSource = SKAudioNode()
        audioSource?.outputAudioMixerGroup = component.outputMixer
        
        // Update UI text
        component.resultText = gameWon ? "You have successfully escaped" : "You are still trapped in it"
        component.scoreText = "Score\n \(score)"
        component.timeText = "Time\n \(Int(time.rounded()))"
        
        if !gameWon {
            playSound(sound: component.soundClip2)
            component.resultText1 = gameWon ? "You have successfully escaped" : "You are still trapped in it"
            component.scoreText1 = "Score\n \(score)"
            component.timeText1 = "Time\n \(Int(time.rounded()))"
        } else {
            playSound(sound: component.soundClip1)
            component.resultText1 = ""
            component.scoreText1 = ""
            component.timeText1 = ""
            component.mirrortext = ""
        }
    }
    
    // MARK: - Helper Methods
    private func destroyGeneratedItems() {
        for tag in component.tagsToDestroy {
            // In SpriteKit, we can't directly use GameObject.FindGameObjectsWithTag,
            // so we assume these are managed by a scene or parent node.
            // We simulate this by searching through all nodes with the given tag.
            // Note: This requires custom tagging system in SpriteKit (e.g., using `userData`).
            // For now, we use a placeholder approach.
            
            // Assuming there's a way to tag nodes via userData (e.g., a key-value store)
            // This is a simplified version ¡ª actual implementation depends on how objects are tagged.
            let nodes = SKScene.current()?.children.compactMap { $0 as? SKNode } ?? []
            for node in nodes {
                if let tagValue = node.userData?[.tag] as? String, tagValue == tag {
                    node.removeFromParent()
                }
            }
        }
    }
    
    private func playSound(sound: SoundAsset?) {
        guard let soundAsset = sound else { return }
        guard let audioNode = audioSource else { return }
        
        // Add audio node to scene if not already present
        if audioNode.parent == nil {
            SKScene.current()?.addChild(audioNode)
        }
        
        // Play one-shot sound
        audioNode.playSoundFileNamed(soundAsset.name, at: .zero, loops: false)
    }
}

// MARK: - Extensions & Helpers
extension SKNode {
    static var current: SKScene? {
        // This would be set based on context (e.g., from view controller)
        // In practice, you'd pass this in from the SceneDelegate or View Coordinator
        // TODO [Migrate]: Implement proper scene context injection mechanism
        return nil
    }
}

// MARK: - Audio Asset Definition
struct SoundAsset: Equatable {
    let name: String
    let bundle: Bundle?
    
    init(name: String, bundle: Bundle? = nil) {
        self.name = name
        self.bundle = bundle
    }
}

// MARK: - User Defaults Extension
extension UserDefaults {
    var gameWon: Bool {
        bool(forKey: "GameWon")
    }
    
    var score: Int {
        integer(forKey: "Score")
    }
    
    var time: Float {
        float(forKey: "Time")
    }
}

// MARK: - SwiftUI View Integration Example (Optional)
struct GameOverView: View {
    @StateObject private var managerSystem = GameOverManagerSystem(
        component: GameOverManagerComponent(
            soundClip1: SoundAsset(name: "success.wav"),
            soundClip2: SoundAsset(name: "failure.wav"),
            tagsToDestroy: ["GeneratedItem", "Obstacle"],
            outputMixer: nil // Placeholder; actual mixer needs to be injected
        )
    )
    
    var body: some View {
        VStack(spacing: 20) {
            Text(managerSystem.component.resultText)
                .font(.title)
                .foregroundColor(.primary)
            
            Text(managerSystem.component.scoreText)
                .font(.headline)
            
            Text(managerSystem.component.timeText)
                .font(.headline)
            
            if !managerSystem.component.resultText1.isEmpty {
                Text(managerSystem.component.resultText1)
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text(managerSystem.component.scoreText1)
                    .font(.subheadline)
                
                Text(managerSystem.component.timeText1)
                    .font(.subheadline)
            }
            
            Text(managerSystem.component.mirrortext)
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
        .onAppear {
            managerSystem.start()
        }
    }
}