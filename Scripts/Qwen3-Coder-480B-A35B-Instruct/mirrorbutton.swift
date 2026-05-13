import SwiftUI
import SpriteKit

// MARK: - Component (Data)
struct MirrorButtonData {
    var originalColor: Color = .white
    var hoverColor: Color = .blue
    var isButtonOn: Bool = false
    var textColor: Color = .white
}

// MARK: - System (Logic)
class MirrorButtonSystem: ObservableObject {
    @Published var component: MirrorButtonData
    
    // [New Fact] SwiftUI doesn't have direct equivalent to Start(), but we can initialize in constructor
    init() {
        self.component = MirrorButtonData()
        // Original Start() logic would go here
        // textComponent = GetComponent<Text>(); -> handled by SwiftUI Text view
        // originalColor = textComponent.color; -> set during initialization
        component.originalColor = component.textColor
    }
    
    // [Negative Transfer] No direct equivalent to Update() in SwiftUI, using @Published and View updates instead
    func update() {
        // [Positive Transfer] Preserving the core logic from Update()
        if component.isButtonOn {
            component.textColor = component.hoverColor
        } else {
            component.textColor = component.originalColor
        }
    }
    
    // Method to simulate button state change
    func setButtonState(_ isOn: Bool) {
        component.isButtonOn = isOn
        update()
    }
}

// MARK: - View (Visual Representation)
struct MirrorButtonView: View {
    @ObservedObject var system: MirrorButtonSystem
    var text: String = "Mirror Button"
    
    var body: some View {
        Text(text)
            .foregroundColor(system.component.textColor)
            // [New Fact] Adding platform-specific interaction handling
            .onTapGesture {
                #if os(iOS)
                // iOS touch interaction
                system.setButtonState(!system.component.isButtonOn)
                #endif
            }
            .onLongPressGesture {
                #if os(iOS)
                // iOS long press interaction
                system.setButtonState(true)
                #endif
            }
            .onHover { hovering in
                #if os(macOS)
                // macOS mouse hover interaction
                system.setButtonState(hovering)
                #endif
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        #if os(visionOS)
                        // visionOS hand/gaze interaction
                        system.setButtonState(true)
                        #endif
                    }
            )
    }
}

// [New Fact] Preview provider for SwiftUI preview
struct MirrorButtonView_Previews: PreviewProvider {
    static var previews: some View {
        MirrorButtonView(system: MirrorButtonSystem())
    }
}