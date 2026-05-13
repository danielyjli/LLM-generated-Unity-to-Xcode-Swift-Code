import SwiftUI
import SpriteKit
import AVFoundation

// MARK: - Component (Data)
struct GameOverData {
    var resultText: String = ""
    var scoreText: String = ""
    var timeText: String = ""
    var resultText1: String = ""
    var scoreText1: String = ""
    var timeText1: String = ""
    var mirrortext: String = ""
    
    // Audio clips would be loaded from bundle
    var soundClip1Name: String = ""
    var soundClip2Name: String = ""
    
    var tagsToDestroy: [String] = []
}

// MARK: - System (Logic)
class GameOverManager: ObservableObject {
    @Published var data: GameOverData
    
    private var audioPlayer: AVAudioPlayer?
    
    // [Positive Transfer]
    // Similar initialization pattern to Unity's Start() method
    init() {
        self.data = GameOverData()
        setup()
    }
    
    // [Positive Transfer]
    // Equivalent to Unity's Start() method
    private func setup() {
        destroyGeneratedItems()
        
        // TODO: Implement PlayerPrefs equivalent for iOS/macOS
        // For now using mock values
        let gameWon = UserDefaults.standard.integer(forKey: "GameWon") == 1
        let score = UserDefaults.standard.integer(forKey: "Score")
        let time = UserDefaults.standard.float(forKey: "Time")
        
        // Set text values
        data.resultText = gameWon ? "You have successfully escaped" : "You are still trapped in it"
        data.scoreText = "Score\n \(score)"
        data.timeText = "Time\n \(Int(round(Double(time))))"
        
        if !gameWon {
            playSound(soundClip2Name: data.soundClip2Name)
            data.resultText1 = gameWon ? "You have successfully escaped" : "You are still trapped in it"
            data.scoreText1 = "Score\n \(score)"
            data.timeText1 = "Time\n \(Int(round(Double(time))))"
        } else {
            playSound(soundClip1Name: data.soundClip1Name)
            data.resultText1 = ""
            data.scoreText1 = ""
            data.timeText1 = ""
            data.mirrortext = ""
        }
    }
    
    // [Negative Transfer]
    // Unity's Destroy functionality doesn't have direct equivalent in SwiftUI
    // This is a conceptual translation that would need platform-specific implementation
    private func destroyGeneratedItems() {
        // [New Fact]
        // In SwiftUI/SpriteKit, object management is typically handled by the framework
        // This would need to be implemented based on how objects are tracked in the specific app
        /*
         // 查找并销毁所有生成的道具实例
         // Find and destroy all generated item instances
         for tag in data.tagsToDestroy {
             // Implementation depends on how objects are managed in the SwiftUI/SpriteKit hierarchy
             // TODO [Migrate]: Platform-specific object destruction logic needed
         }
         */
    }
    
    // [New Fact]
    // Audio handling in Swift uses AVFoundation instead of Unity's AudioSource
    private func playSound(soundClipName: String) {
        guard !soundClipName.isEmpty else { return }
        
        // TODO [Migrate]: Load actual audio files from bundle
        /*
        if let path = Bundle.main.path(forResource: soundClipName, ofType: nil) {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Failed to play sound: \(error)")
            }
        }
         */
    }
}

// MARK: - SwiftUI View
struct GameOverView: View {
    @StateObject private var manager = GameOverManager()
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Primary result display
                VStack {
                    Text(manager.data.resultText)
                        .foregroundColor(.white)
                        .font(.title)
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Text(manager.data.scoreText)
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        Text(manager.data.timeText)
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                
                // Secondary result display
                VStack {
                    Text(manager.data.resultText1)
                        .foregroundColor(.white)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Text(manager.data.scoreText1)
                            .foregroundColor(.white)
                            .font(.body)
                        
                        Text(manager.data.timeText1)
                            .foregroundColor(.white)
                            .font(.body)
                    }
                }
                
                // Mirror text
                Text(manager.data.mirrortext)
                    .foregroundColor(.white)
                    .font(.body)
            }
        }
        .onAppear {
            // This mimics Unity's Start() behavior when the view appears
        }
    }
}

// MARK: - Preview
struct GameOverView_Previews: PreviewProvider {
    static var previews: some View {
        GameOverView()
    }
}