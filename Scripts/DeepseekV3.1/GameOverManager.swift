import SwiftUI
import SpriteKit
import AVFoundation

// MARK: - Component
struct GameOverComponent {
    var resultText: String = ""
    var scoreText: String = ""
    var timeText: String = ""
    var resultText1: String = ""
    var scoreText1: String = ""
    var timeText1: String = ""
    var mirrortext: String = ""
    var gameWon: Bool = false
    var score: Int = 0
    var time: Float = 0
    var tagsToDestroy: [String] = []
}

// MARK: - System
struct GameOverSystem: View {
    @State private var component = GameOverComponent()
    @State private var audioPlayer: AVAudioPlayer?
    private let soundClip1: URL? = Bundle.main.url(forResource: "soundClip1", withExtension: "wav")
    private let soundClip2: URL? = Bundle.main.url(forResource: "soundClip2", withExtension: "wav")
    
    var body: some View {
        VStack {
            // Main result display
            Text(component.resultText)
                .font(.title)
            Text(component.scoreText)
                .font(.headline)
            Text(component.timeText)
                .font(.headline)
            
            // Mirror display (only shown when game is lost)
            if !component.gameWon {
                Text(component.resultText1)
                    .font(.title)
                Text(component.scoreText1)
                    .font(.headline)
                Text(component.timeText1)
                    .font(.headline)
                Text(component.mirrortext)
                    .font(.caption)
            }
        }
        .onAppear {
            setupGameOver()
        }
    }
    
    private func setupGameOver() {
        // [Positive Transfer] Migrated PlayerPrefs to UserDefaults
        let gameWon = UserDefaults.standard.bool(forKey: "GameWon")
        let score = UserDefaults.standard.integer(forKey: "Score")
        let time = UserDefaults.standard.float(forKey: "Time")
        
        component.gameWon = gameWon
        component.score = score
        component.time = time
        
        component.resultText = gameWon ? "You have successfully escaped" : "You are still trapped in it"
        component.scoreText = "Score\n \(score)"
        component.timeText = "Time\n \(Int(round(time)))"
        
        if !gameWon {
            playSound(soundClip: soundClip2)
            component.resultText1 = "You are still trapped in it"
            component.scoreText1 = "Score\n \(score)"
            component.timeText1 = "Time\n \(Int(round(time)))"
            component.mirrortext = "" // TODO: Set appropriate mirror text if needed
        } else {
            playSound(soundClip: soundClip1)
            component.resultText1 = ""
            component.scoreText1 = ""
            component.timeText1 = ""
            component.mirrortext = ""
        }
        
        destroyGeneratedItems()
    }
    
    private func playSound(soundClip: URL?) {
        guard let url = soundClip else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
    
    private func destroyGeneratedItems() {
        // [Negative Transfer] GameObject.FindGameObjectsWithTag functionality doesn't exist in SwiftUI
        // This would require a different approach in SwiftUI architecture
        // TODO [Migrate]: Implement proper scene cleanup mechanism
        print("Items with tags \(component.tagsToDestroy) would be destroyed here")
    }
    
    // MARK: - Input Handlers
    private func handleMacOSInput() {
        // macOS keyboard and mouse input through gestures
        // TODO: Implement specific macOS input handling
    }
    
    private func handleIOSInput() {
        // iOS touch gestures (tap, drag, long press)
        // TODO: Implement specific iOS touch handling
    }
    
    private func handleVisionOSInput() {
        // visionOS hand gestures or gaze input
        // TODO: Implement specific visionOS gesture handling
    }
}