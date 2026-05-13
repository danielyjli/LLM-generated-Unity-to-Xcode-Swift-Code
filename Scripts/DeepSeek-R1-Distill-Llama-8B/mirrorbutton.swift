import SwiftUI
import SpriteKit

struct MirrorButtonSystem: System {
    private var textComponent: Text?
    private var originalColor: Color
    private var hoverColor: Color
    private var clickableText: ClickableText
    private var buttonIsPressed: Bool = false
    
    init() {
        // Initialize the text component and original color
        textComponent = nil
        originalColor = Text().color
    }
    
    func update(_ deltaTime: Double) {
        if buttonIsPressed {
            textComponent?.color = hoverColor
        } else {
            textComponent?.color = originalColor
        }
    }
    
    func handleMouseEvents(_ sender: NSCustomEvent) {
        if sender.type == .mouseDown {
            buttonIsPressed = true
        } else if sender.type == .mouseUp {
            buttonIsPressed = false
        } else if sender.type == .mouseDrag {
            buttonIsPressed = true
        }
    }
    
    func handleTouchEvents(_ sender: NSCustomEvent) {
        if sender.type == .touchDown {
            buttonIsPressed = true
        } else if sender.type == .touchUp {
            buttonIsPressed = false
        } else if sender.type == .touchDrag {
            buttonIsPressed = true
        }
    }
    
    func handleVisionOSEvents(_ sender: NSCustomEvent) {
        if sender.type == .drag {
            buttonIsPressed = true
        } else if sender.type == .tap {
            buttonIsPressed = true
        }
    }
    
    func onCollisionEnter(_ other: Collider) {
        debugPrint("Button pressed via collision")
        buttonIsPressed = true
    }
}

struct MirrorButtonComponent: Component {
    @System var system: MirrorButtonSystem
    private var text: Text
    var hoverColor: Color
    private var clickableText: ClickableText
    
    init() {
        text = Text()
        clickableText = ClickableText()
    }
    
    var body: some Scene {
        return Scene(
            type: .ui,
            content: {
                text
            },
            physicsBody: PhysicsBody(),
            collisionHandling: .disjoint
        )
    }
    
    func handleMouseDown(_ sender: NSCustomEvent) {
        system.buttonIsPressed = true
    }
    
    func handleMouseUp(_ sender: NSCustomEvent) {
        system.buttonIsPressed = false
    }
    
    func handleMouseDrag(_ sender: NSCustomEvent) {
        system.buttonIsPressed = true
    }
    
    func handleTouchDown(_ sender: NSCustomEvent) {
        system.buttonIsPressed = true
    }
    
    func handleTouchUp(_ sender: NSCustomEvent) {
        system.buttonIsPressed = false
    }
    
    func handleTouchDrag(_ sender: NSCustomEvent) {
        system.buttonIsPressed = true
    }
    
    func handleDrag(_ sender: NSCustomEvent) {
        system.buttonIsPressed = true
    }
    
    func handleTap(_ sender: NSCustomEvent) {
        system.buttonIsPressed = true
    }
    
    func onCollisionEnter(_ other: Collider) {
        system.buttonIsPressed = true
    }
}