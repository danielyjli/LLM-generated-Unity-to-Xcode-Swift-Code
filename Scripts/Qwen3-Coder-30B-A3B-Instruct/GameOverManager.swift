import SwiftUI
import SpriteKit
import AVFoundation

// MARK: - GameOverManager System
class GameOverManagerSystem: ObservableObject {
    @Published var resultText: String = ""
    @Published var scoreText: String = ""
    @Published var timeText: String = ""
    @Published var resultText1: String = ""
    @Published var scoreText1: String = ""
    @Published var timeText1: String = ""
    @Published var mirrortext: String = ""
    
    private var audioPlayer: AVAudioPlayer?
    private var soundClip1: AVAudioPlayer?
    private var soundClip2: AVAudioPlayer?
    
    // MARK: - Configuration
    var tagsToDestroy: [String] = []
    var outputMixer: String = ""
    
    init() {
        setupAudioPlayers()
    }
    
    private func setupAudioPlayers() {
        // Initialize audio players for soundClip1 and soundClip2
        // Note: Actual audio file loading would require additional setup
    }
    
    // MARK: - Lifecycle Methods
    func start() {
        destroyGeneratedItems()
        let gameWon = UserDefaults.standard.bool(forKey: "GameWon")
        let score = UserDefaults.standard.integer(forKey: "Score")
        let time = UserDefaults.standard.float(forKey: "Time")
        
        resultText = gameWon ? "You have successfully escaped" : "You are still trapped in it"
        scoreText = "Score\n \(score)"
        timeText = "Time\n \(Int(time))"
        
        if !gameWon {
            playSound(soundClip2)
            resultText1 = gameWon ? "You have successfully escaped" : "You are still trapped in it"
            scoreText1 = "Score\n \(score)"
            timeText1 = "Time\n \(Int(time))"
        } else {
            playSound(soundClip1)
            resultText1 = ""
            scoreText1 = ""
            timeText1 = ""
            mirrortext = ""
        }
    }
    
    // MARK: - Private Methods
    private func destroyGeneratedItems() {
        // Find and destroy all generated item instances by tag
        for tag in tagsToDestroy {
            // In SwiftUI/SpriteKit environment, this would typically involve
            // removing nodes from the scene or managing entity lifecycle
            // This is a placeholder for actual implementation
        }
    }
    
    private func playSound(_ soundClip: AVAudioPlayer?) {
        // Play audio clip if available
        // Implementation depends on how audio files are loaded
    }
}

// MARK: - GameOverManager Component
struct GameOverManagerComponent: View {
    @StateObject private var system = GameOverManagerSystem()
    
    var body: some View {
        VStack(spacing: 20) {
            Text(system.resultText)
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Text(system.scoreText)
                .font(.headline)
            
            Text(system.timeText)
                .font(.headline)
            
            if !system.resultText1.isEmpty {
                Text(system.resultText1)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                
                Text(system.scoreText1)
                    .font(.subheadline)
                
                Text(system.timeText1)
                    .font(.subheadline)
            }
            
            Text(system.mirrortext)
                .font(.body)
        }
        .onAppear {
            system.start()
        }
    }
}