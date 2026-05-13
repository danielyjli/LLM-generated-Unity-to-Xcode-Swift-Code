using UnityEngine
using SpriteKit

struct Property: Component {
    var antiGravityForce = 0.0
    var isInAntiGravityField = false
}

struct Physics: Component {
    var rb: Rigidbody2D?
    var antiGravityForce = 0.0
}

extension Property {
    var isAntiGravityField: Bool {
        get { return self.isInAntiGravityField }
        set { self.isInAntiGravityField = $value }
    }
}

extension Physics {
    func applyAntiGravityForce() {
        if let rb = self.rb {
            rb.AddForce(Vector2.up * self.antiGravityForce, forceMode: .force)
        }
    }
}

struct Platform {
    static let mac = "macOS"
    static let iOS = "iOS"
    static let visionOS = "VisionOS"
}

struct InputHandler {
    static func handleInputs(for platform: Platform, onKeyPress: @escaping ((UInt8, UInt8) -> Bool)) {
        switch platform {
        case .mac:
            // macOS-specific input handling
            break
        case .iOS:
            // iOS-specific input handling
            break
        case .visionOS:
            // VisionOS-specific input handling
            break
        }
    }
}

struct SceneSetup {
    static func setupScene() -> GameObject {
        let scene = Scene()
        let obj = Object()
        obj.name = "Props"
        
        let property = Property()
        let physics = Physics()
        let trigger = Trigger2D()
        
        obj.addComponents([property, physics, trigger])
        scene.rootNode = obj
        
        return obj
    }
}