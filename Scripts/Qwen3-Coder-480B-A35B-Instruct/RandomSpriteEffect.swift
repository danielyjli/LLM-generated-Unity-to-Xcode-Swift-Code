import SwiftUI
import SpriteKit

// MARK: - Component (Data)
struct RandomSpriteEffectComponent {
    var minGrayScale: Float = 0.0
    var maxGrayScale: Float = 1.0
    var minAlpha: Float = 0.0
    var maxAlpha: Float = 1.0
    
    // Internal state
    var targetGrayScale: Float = 0.0
    var targetAlpha: Float = 0.0
    var transitionSpeed: Float = 0.5
    var currentColor: Color = .white
}

// MARK: - System (Logic)
class RandomSpriteEffectSystem: ObservableObject {
    @Published var component: RandomSpriteEffectComponent
    private var needsRandomization = true
    
    init(component: RandomSpriteEffectComponent = RandomSpriteEffectComponent()) {
        self.component = component
    }
    
    // [Positive Transfer]
    /// Equivalent to Unity's Start() method
    func setup() {
        randomizeSpriteEffect()
    }
    
    // [Positive Transfer]
    /// Equivalent to Unity's Update() method
    func update() {
        let currentGrayScale = getGrayScale(from: component.currentColor)
        let currentAlpha = Float(component.currentColor.opacity)
        
        if abs(currentGrayScale - component.targetGrayScale) > 0.01 ||
            abs(currentAlpha - component.targetAlpha) > 0.01 {
            // 进行平滑的过渡 (Perform smooth transition)
            let targetColor = Color(
                red: Double(component.targetGrayScale),
                green: Double(component.targetGrayScale),
                blue: Double(component.targetGrayScale),
                opacity: Double(component.targetAlpha)
            )
            
            // TODO: Replace with proper deltaTime implementation
            let deltaTime: Float = 1/60 // Assuming 60 FPS
            component.currentColor = lerpColor(from: component.currentColor, to: targetColor, t: component.transitionSpeed * deltaTime)
        } else {
            // 达到目标颜色后，随机生成新的目标颜色 (After reaching target color, randomly generate new target color)
            randomizeSpriteEffect()
        }
    }
    
    // [Positive Transfer]
    private func randomizeSpriteEffect() {
        component.targetGrayScale = Float.random(in: component.minGrayScale...component.maxGrayScale)
        component.targetAlpha = Float.random(in: component.minAlpha...component.maxAlpha)
    }
    
    // Helper method to calculate grayscale value from Color
    private func getGrayScale(from color: Color) -> Float {
        let components = color.cgColor?.components ?? [1.0, 1.0, 1.0, 1.0]
        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        return 0.299 * red + 0.587 * green + 0.114 * blue
    }
    
    // Linear interpolation between two colors
    private func lerpColor(from startColor: Color, to endColor: Color, t: Float) -> Color {
        let startComponents = startColor.cgColor?.components ?? [1.0, 1.0, 1.0, 1.0]
        let endComponents = endColor.cgColor?.components ?? [1.0, 1.0, 1.0, 1.0]
        
        let r = startComponents[0] + (endComponents[0] - startComponents[0]) * Double(t)
        let g = startComponents[1] + (endComponents[1] - startComponents[1]) * Double(t)
        let b = startComponents[2] + (endComponents[2] - startComponents[2]) * Double(t)
        let a = startComponents[3] + (endComponents[3] - startComponents[3]) * Double(t)
        
        return Color(red: r, green: g, blue: b, opacity: a)
    }
}

// MARK: - View Implementation
struct RandomSpriteEffectView: View {
    @StateObject private var system = RandomSpriteEffectSystem()
    
    var body: some View {
        SpriteView(scene: createScene())
            .onAppear {
                system.setup()
            }
            .onReceive(Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()) { _ in
                system.update()
            }
    }
    
    private func createScene() -> SKScene {
        let scene = SKScene(size: CGSize(width: 400, height: 400))
        scene.backgroundColor = .clear
        return scene
    }
}

// MARK: - Platform-Specific Input Extensions

// macOS Input Implementation
#if os(macOS)
extension RandomSpriteEffectView {
    // macOS uses keyboard and mouse input through gestures
    func addMacOSGestures() {
        // TODO [Migrate]: Add macOS specific mouse/keyboard gesture handling if needed
    }
}
#endif

// iOS Input Implementation
#if os(iOS)
extension RandomSpriteEffectView {
    // iOS uses touch gestures (tap, drag, long press)
    func addIOSGestures() {
        // TODO [Migrate]: Add iOS specific touch gesture handling if needed
    }
}
#endif

// visionOS Input Implementation
#if os(visionOS)
extension RandomSpriteEffectView {
    // visionOS uses hand gestures or gaze input gesture system
    func addVisionOSGestures() {
        // TODO [Migrate]: Add visionOS specific hand/gaze gesture handling if needed
    }
}
#endif

// [New Fact]
/// Preview for Xcode canvas
struct RandomSpriteEffectView_Previews: PreviewProvider {
    static var previews: some View {
        RandomSpriteEffectView()
    }
}