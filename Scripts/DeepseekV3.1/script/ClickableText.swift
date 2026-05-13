import SwiftUI
import SpriteKit
import AVFoundation

// MARK: - Component
struct ClickableTextComponent {
    var originalColor: Color
    let hoverColor: Color
    let sceneName: String
    let soundClip: String?
    let outputMixer: AVAudioMixerNode?
    var buttonOn: Bool = false
    var audioPlayer: AVAudioPlayer?
}

// MARK: - System
struct ClickableTextView: View {
    @State private var component: ClickableTextComponent
    @State private var textColor: Color
    
    init(originalColor: Color, hoverColor: Color, sceneName: String, soundClip: String? = nil, outputMixer: AVAudioMixerNode? = nil) {
        _component = State(initialValue: ClickableTextComponent(
            originalColor: originalColor,
            hoverColor: hoverColor,
            sceneName: sceneName,
            soundClip: soundClip,
            outputMixer: outputMixer
        ))
        _textColor = State(initialValue: originalColor)
    }
    
    var body: some View {
        Text("Clickable Text")
            .foregroundColor(textColor)
            .contentShape(Rectangle())
            .onHover { hovering in
                if hovering {
                    onPointerEnter()
                } else {
                    onPointerExit()
                }
            }
            .onTapGesture {
                onPointerClick()
            }
            .highPriorityGesture(
                TapGesture()
                    .onEnded { _ in
                        onPointerClick()
                    }
            )
    }
    
    // [Positive Transfer] Direct migration of hover logic with audio feedback
    private func onPointerEnter() {
        playSound()
        textColor = component.hoverColor
        component.buttonOn = true
    }
    
    // [Positive Transfer] Direct migration of exit logic
    private func onPointerExit() {
        textColor = component.originalColor
        component.buttonOn = false
    }
    
    // [Positive Transfer] Scene loading logic with platform adaptation
    private func onPointerClick() {
        // TODO [Migrate]: SceneManager.LoadScene equivalent in SwiftUI
        // For SwiftUI, we would typically use navigation or presentation modifiers
        // This would need to be integrated with the parent view's navigation state
        print("Would load scene: \(component.sceneName)")
    }
    
    // [Positive Transfer] Audio playback with mixer support
    private func playSound() {
        guard let soundClip = component.soundClip,
              let url = Bundle.main.url(forResource: soundClip, withExtension: nil) else {
            return
        }
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            if let mixer = component.outputMixer {
                // TODO [Migrate]: AVAudioMixerNode connection setup
                // This requires more complex audio engine setup
            }
            audioPlayer.play()
            component.audioPlayer = audioPlayer
        } catch {
            print("Error playing sound: \(error)")
        }
    }
}

// MARK: - iOS Touch Implementation
extension ClickableTextView {
    // [New Fact] iOS-specific touch gesture implementation
    private var iOSGesture: some Gesture {
        SimultaneousGesture(
            LongPressGesture(minimumDuration: 0.01)
                .onChanged { _ in
                    onPointerEnter()
                }
                .onEnded { _ in
                    onPointerExit()
                },
            TapGesture()
                .onEnded { _ in
                    onPointerClick()
                }
        )
    }
}

// MARK: - visionOS Hand Gesture Implementation
extension ClickableTextView {
    // [New Fact] visionOS-specific hand gesture implementation
    private var visionOSGesture: some Gesture {
        SpatialTapGesture()
            .onEnded { _ in
                onPointerClick()
            }
    }
}