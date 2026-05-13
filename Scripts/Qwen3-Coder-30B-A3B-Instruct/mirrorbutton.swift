import SwiftUI
import SpriteKit

// MARK: - Component Data
struct MirrorButtonComponent: Component {
    var textComponent: SKLabelNode
    var originalColor: UIColor
    var hoverColor: UIColor
    var buttonOn: Bool = false
}

// MARK: - System Logic
class MirrorButtonSystem: ObservableObject {
    @Published var components: [UUID: MirrorButtonComponent] = [:]
    
    func initializeComponent(id: UUID, textNode: SKLabelNode, hoverColor: UIColor) {
        let component = MirrorButtonComponent(
            textComponent: textNode,
            originalColor: textNode.color,
            hoverColor: hoverColor,
            buttonOn: false
        )
        components[id] = component
    }
    
    func setButtonState(id: UUID, isOn: Bool) {
        guard var component = components[id] else { return }
        component.buttonOn = isOn
        components[id] = component
    }
    
    func update() {
        for (id, component) in components {
            if component.buttonOn {
                component.textComponent.color = component.hoverColor
            } else {
                component.textComponent.color = component.originalColor
            }
            components[id] = component
        }
    }
}

// MARK: - View Implementation
struct MirrorButtonView: View {
    @StateObject private var system = MirrorButtonSystem()
    private let id = UUID()
    private let textNode: SKLabelNode
    private let hoverColor: UIColor
    
    init(textNode: SKLabelNode, hoverColor: UIColor) {
        self.textNode = textNode
        self.hoverColor = hoverColor
    }
    
    var body: some View {
        ZStack {
            // Placeholder for SpriteKit scene
            Rectangle()
                .fill(Color.clear)
                .onAppear {
                    system.initializeComponent(id: id, textNode: textNode, hoverColor: hoverColor)
                }
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("UpdateMirrorButton"))) { _ in
            system.update()
        }
    }
}

// MARK: - Platform-Specific Input Handling

// MARK: - macOS Input Handler
#if os(macOS)
extension MirrorButtonSystem {
    func handleMouseHover(isOver: Bool) {
        setButtonState(id: id, isOn: isOver)
    }
}
#endif

// MARK: - iOS Input Handler
#if os(iOS)
extension MirrorButtonSystem {
    func handleTap() {
        setButtonState(id: id, isOn: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setButtonState(id: id, isOn: false)
        }
    }
    
    func handleLongPress() {
        setButtonState(id: id, isOn: true)
    }
}
#endif

// MARK: - visionOS Input Handler
#if os(visionOS)
extension MirrorButtonSystem {
    func handleGazeEnter() {
        setButtonState(id: id, isOn: true)
    }
    
    func handleGazeExit() {
        setButtonState(id: id, isOn: false)
    }
    
    func handleHandGesture() {
        setButtonState(id: id, isOn: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.setButtonState(id: id, isOn: false)
        }
    }
}
#endif

// MARK: - Helper Extensions
extension Notification.Name {
    static let updateMirrorButton = Notification.Name("UpdateMirrorButton")
}

protocol Component {
    var id: UUID { get }
}

extension Component {
    var id: UUID {
        UUID()
    }
}