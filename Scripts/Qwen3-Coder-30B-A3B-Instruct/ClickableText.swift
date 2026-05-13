import SwiftUI
import SpriteKit

// MARK: - Component Data
struct ClickableTextComponent: Component {
    var originalColor: Color
    var hoverColor: Color
    var sceneName: String
    var soundClip: String
    var outputMixer: String
    var buttonOn: Bool = false
}

// MARK: - System Logic
class ClickableTextSystem: ObservableObject {
    @Published var components: [EntityID: ClickableTextComponent] = [:]
    
    func initialize(_ entityID: EntityID, textComponent: SKLabelNode, hoverColor: Color, sceneName: String, soundClip: String, outputMixer: String) {
        let originalColor = Color(uiColor: textComponent.textColor)
        components[entityID] = ClickableTextComponent(
            originalColor: originalColor,
            hoverColor: hoverColor,
            sceneName: sceneName,
            soundClip: soundClip,
            outputMixer: outputMixer
        )
        
        // Set up initial state
        textComponent.textColor = originalColor.uiColor
    }
    
    func handleHover(_ entityID: EntityID, textComponent: SKLabelNode) {
        guard var component = components[entityID] else { return }
        
        // Play sound effect
        playSound(component.soundClip)
        
        // Change color
        textComponent.textColor = component.hoverColor.uiColor
        component.buttonOn = true
        components[entityID] = component
    }
    
    func handleExit(_ entityID: EntityID, textComponent: SKLabelNode) {
        guard var component = components[entityID] else { return }
        
        // Restore original color
        textComponent.textColor = component.originalColor.uiColor
        component.buttonOn = false
        components[entityID] = component
    }
    
    func handleClick(_ entityID: EntityID) {
        guard let component = components[entityID] else { return }
        
        // Load scene
        loadScene(component.sceneName)
    }
    
    private func playSound(_ soundName: String) {
        // Implementation would depend on how audio is handled in your Swift project
        // This is a placeholder for actual audio playback logic
        print("Playing sound: \(soundName)")
    }
    
    private func loadScene(_ sceneName: String) {
        // Implementation would depend on your scene management system
        // This is a placeholder for actual scene loading logic
        print("Loading scene: \(sceneName)")
    }
}

// MARK: - View Implementation
struct ClickableTextView: View {
    let entityID: EntityID
    let textComponent: SKLabelNode
    let system: ClickableTextSystem
    
    var body: some View {
        ZStack {
            Text(textComponent.text ?? "")
                .foregroundColor(Color(uiColor: textComponent.textColor))
                .onHover(perform: { isHovering in
                    if isHovering {
                        system.handleHover(entityID, textComponent: textComponent)
                    } else {
                        system.handleExit(entityID, textComponent: textComponent)
                    }
                })
                .onTapGesture {
                    system.handleClick(entityID)
                }
        }
    }
}

// MARK: - Platform-Specific Input Handling
extension ClickableTextView {
    // macOS input handling
    func handleMouseInput() {
        // Mouse hover and click events for macOS
    }
    
    // iOS input handling
    func handleTouchInput() {
        // Touch gestures for iOS (tap, drag, long press)
    }
    
    // visionOS input handling
    func handleHandInput() {
        // Hand gestures or gaze input for visionOS
    }
}

// MARK: - Helper Extensions
extension Color {
    init(uiColor: UIColor) {
        self.init(UIColor(uiColor: uiColor))
    }
    
    var uiColor: UIColor {
        UIColor(self)
    }
}

// MARK: - Type Aliases
typealias EntityID = UUID
protocol Component {}

// MARK: - Placeholder for Scene Management
func loadScene(_ sceneName: String) {
    // Implementation depends on your scene management architecture
}