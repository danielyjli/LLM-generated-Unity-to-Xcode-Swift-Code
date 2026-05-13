import SwiftUI
import SpriteKit

// [Positive Transfer] - This class uses Unity's MonoBehaviour pattern with event handlers for UI interactions.
// [Positive Transfer] - Translated IPointerEnterHandler, IPointerExitHandler, IPointerClickHandler to SwiftUI gesture handlers.
// [Positive Transfer] - Audio playback via AudioSource and AudioClip is preserved using AVFoundation.
// [Negative Transfer] - Unity's SceneManager.LoadScene is replaced with SwiftUI's NavigationView and View transitions.
// [New Fact] - On macOS/iOS/visionOS, input is handled via gestures (mouse/touch/hand/gaze) instead of Unity's EventSystem.

struct ClickableText: View {
    // Component data
    @State private var textComponent: String = ""
    @State private var originalColor: Color = .black
    @State private var hoverColor: Color = .blue
    @State private var sceneName: String = ""
    @State private var soundClip: URL? = nil
    @State private var outputMixer: AudioMixerGroup? = nil
    @State private var audioSource: AVAudioPlayer?
    @State private var buttonOn: Bool = false
    
    // System logic
    private let sceneManager = SceneNavigator() // Simulates Unity's SceneManager
    
    // MARK: - Lifecycle
    init(text: String, originalColor: Color, hoverColor: Color, sceneName: String, soundClip: URL?, outputMixer: AudioMixerGroup?) {
        self._textComponent = State(initialValue: text)
        self._originalColor = State(initialValue: originalColor)
        self._hoverColor = State(initialValue: hoverColor)
        self._sceneName = State(initialValue: sceneName)
        self._soundClip = State(initialValue: soundClip)
        self._outputMixer = State(initialValue: outputMixer)
    }
    
    var body: some View {
        Text(textComponent)
            .font(.headline)
            .foregroundColor(buttonOn ? hoverColor : originalColor)
            .padding()
            .background(buttonOn ? Color.gray.opacity(0.3) : Color.clear)
            .cornerRadius(8)
            .onTapGesture {
                playSound()
                navigateToScene()
            }
            .onHover { isHovering in
                if isHovering {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        buttonOn = true
                        playSound()
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        buttonOn = false
                    }
                }
            }
            .onLongPressGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    buttonOn = true
                    playSound()
                }
            }
            .onChange(of: buttonOn) { newValue in
                // Update visual state based on hover/click state
                if !newValue {
                    // Reset color on exit
                    withAnimation(.easeInOut(duration: 0.2)) {
                        // No need to change color here since it's already handled by .foregroundColor
                    }
                }
            }
    }
    
    // MARK: - Audio Handling
    private func playSound() {
        guard let url = soundClip else { return }
        
        do {
            audioSource = try AVAudioPlayer(contentsOf: url)
            audioSource?.play()
        } catch {
            print("Failed to load audio file: \(error)")
        }
    }
    
    // MARK: - Scene Navigation
    private func navigateToScene() {
        sceneManager.loadScene(sceneName)
    }
}

// MARK: - Supporting Types
class SceneNavigator {
    func loadScene(_ name: String) {
        // In SwiftUI, navigation is handled via NavigationView and View transitions.
        // For now, we simulate loading a scene by printing the name.
        print("Loading scene: \(name)")
        
        // In a real app, you would use:
        // - NavigationLink(destination: NextView()) to push views
        // - Or use a NavigationStack / NavigationDestination in iOS 16+
    }
}

// MARK: - Audio Mixer Group Simulation
struct AudioMixerGroup: Equatable {
    let name: String
    let volume: Float
    
    static let defaultGroup = AudioMixerGroup(name: "Master", volume: 1.0)
}

// MARK: - Platform-Specific Input Mapping
extension ClickableText {
    // [New Fact] - On macOS: Mouse enter/exit + click ¡ú TapGesture + Hover
    // [New Fact] - On iOS: Touch tap/drag ¡ú TapGesture + LongPressGesture
    // [New Fact] - On visionOS: Hand gesture or gaze ¡ú Gaze-based detection via ARKit/RealityKit
    // This implementation uses SwiftUI¡¯s built-in gesture system which adapts across platforms.
}