import SwiftUI
import SpriteKit
import AVFoundation

// MARK: - Component (Data)
struct ClickableTextComponent {
    var hoverColor: Color
    var sceneName: String
    var soundClip: AVAudioPlayer?
    var outputMixer: AVAudioSession?
    var buttonOn: Bool = false
    var originalColor: Color = .black
    
    // Audio session setup
    init(hoverColor: Color, sceneName: String) {
        self.hoverColor = hoverColor
        self.sceneName = sceneName
        
        // TODO [Migrate] AudioMixerGroup equivalent in Swift requires more complex audio routing setup
        // For now, we'll use basic AVAudioSession
    }
}

// MARK: - System (Logic)
class ClickableTextSystem: ObservableObject {
    @Published var component: ClickableTextComponent
    private var audioPlayer: AVAudioPlayer?
    
    init(hoverColor: Color, sceneName: String) {
        self.component = ClickableTextComponent(hoverColor: hoverColor, sceneName: sceneName)
    }
    
    // [Positive Transfer] Similar to Start() in MonoBehaviour
    func setup(textColor: Color, soundClipURL: URL?) {
        component.originalColor = textColor
        
        // Setup audio player if sound clip is provided
        if let url = soundClipURL {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                // TODO [Migrate] AudioMixerGroup mapping to Swift audio sessions
            } catch {
                print("Failed to initialize audio player: \(error)")
            }
        }
    }
    
    // [Positive Transfer] Mouse enter event handler
    func onPointerEnter() {
        // Play sound
        audioPlayer?.play()
        
        // Change color to hover color
        component.buttonOn = true
    }
    
    // [Positive Transfer] Mouse exit event handler
    func onPointerExit() {
        // Reset color to original
        component.buttonOn = false
    }
    
    // [Positive Transfer] Click event handler
    func onPointerClick() {
        // TODO [Migrate] SceneManager equivalent in Swift depends on navigation architecture
        // This would typically involve calling a navigation method or publishing an event
        print("Load scene: \(component.sceneName)")
    }
}

// MARK: - View Implementation
struct ClickableTextView: View {
    @StateObject private var system: ClickableTextSystem
    @State private var currentColor: Color
    let textColor: Color
    let soundClipURL: URL?
    
    init(hoverColor: Color, sceneName: String, textColor: Color, soundClipURL: URL?) {
        _system = StateObject(wrappedValue: ClickableTextSystem(hoverColor: hoverColor, sceneName: sceneName))
        _currentColor = State(initialValue: textColor)
        self.textColor = textColor
        self.soundClipURL = soundClipURL
    }
    
    var body: some View {
        Text("Clickable Text")
            .foregroundColor(currentColor)
            .onAppear {
                system.setup(textColor: textColor, soundClipURL: soundClipURL)
            }
            .onTapGesture {
                system.onPointerClick()
            }
            .onLongPressGesture(minimumDuration: 0.1) {
                // Hover enter effect
                system.onPointerEnter()
                currentColor = system.component.hoverColor
            } onPressingChanged: { isPressing in
                if !isPressing {
                    // Hover exit effect
                    system.onPointerExit()
                    currentColor = system.component.originalColor
                }
            }
            // macOS mouse events
            .onHover { hovering in
                if hovering {
                    system.onPointerEnter()
                    currentColor = system.component.hoverColor
                } else {
                    system.onPointerExit()
                    currentColor = system.component.originalColor
                }
            }
    }
}

// [New Fact] SwiftUI requires explicit state management for UI updates
// [New Fact] Platform-specific gestures are handled through view modifiers
// [Negative Transfer] No direct equivalent to Unity's EventSystem interfaces (IPointerEnterHandler, etc.)
// [Negative Transfer] No direct equivalent to Unity's SceneManager in SwiftUI (navigation depends on app architecture)