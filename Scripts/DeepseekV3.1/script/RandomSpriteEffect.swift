import SwiftUI
import SpriteKit

// MARK: - Component
struct RandomSpriteEffectComponent {
    var minGrayScale: Float = 0.0
    var maxGrayScale: Float = 1.0
    var minAlpha: Float = 0.0
    var maxAlpha: Float = 1.0
    var transitionSpeed: Float = 0.5
    var targetGrayScale: Float = 0.0
    var targetAlpha: Float = 0.0
    var spriteNode: SKSpriteNode?
}

// MARK: - System
struct RandomSpriteEffectSystem {
    private var component: RandomSpriteEffectComponent
    
    init(component: RandomSpriteEffectComponent) {
        self.component = component
        randomizeSpriteEffect()
    }
    
    // [Positive Transfer] Direct translation of Start method with component initialization
    mutating func setup(with spriteNode: SKSpriteNode) {
        component.spriteNode = spriteNode
        randomizeSpriteEffect()
    }
    
    // [Positive Transfer] Direct translation of Update method with time-based interpolation
    mutating func update(deltaTime: TimeInterval) {
        guard let spriteNode = component.spriteNode,
              let currentColor = spriteNode.color as? UIColor else { return }
        
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        currentColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let currentGrayScale = Float((red + green + blue) / 3.0)
        let currentAlpha = Float(alpha)
        
        if abs(currentGrayScale - component.targetGrayScale) > 0.01 ||
           abs(currentAlpha - component.targetAlpha) > 0.01 {
            
            // Smooth transition using linear interpolation
            let targetColor = UIColor(
                white: CGFloat(component.targetGrayScale),
                alpha: CGFloat(component.targetAlpha)
            )
            
            let t = CGFloat(component.transitionSpeed * Float(deltaTime))
            let lerpedColor = interpolateColor(
                from: currentColor,
                to: targetColor,
                t: min(t, 1.0)
            )
            
            spriteNode.color = lerpedColor
            spriteNode.colorBlendFactor = 1.0
        } else {
            // Reached target color, randomize new target
            randomizeSpriteEffect()
        }
    }
    
    // [Positive Transfer] Direct translation of RandomizeSpriteEffect method
    private mutating func randomizeSpriteEffect() {
        component.targetGrayScale = Float.random(in: component.minGrayScale...component.maxGrayScale)
        component.targetAlpha = Float.random(in: component.minAlpha...component.maxAlpha)
    }
    
    // [New Fact] Color interpolation helper since Swift doesn't have Color.Lerp
    private func interpolateColor(from startColor: UIColor, to endColor: UIColor, t: CGFloat) -> UIColor {
        var startRed: CGFloat = 0, startGreen: CGFloat = 0, startBlue: CGFloat = 0, startAlpha: CGFloat = 0
        var endRed: CGFloat = 0, endGreen: CGFloat = 0, endBlue: CGFloat = 0, endAlpha: CGFloat = 0
        
        startColor.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)
        endColor.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endAlpha)
        
        let red = startRed + (endRed - startRed) * t
        let green = startGreen + (endGreen - startGreen) * t
        let blue = startBlue + (endBlue - startBlue) * t
        let alpha = startAlpha + (endAlpha - startAlpha) * t
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// MARK: - SwiftUI View Wrapper
struct RandomSpriteEffectView: View {
    @State private var system: RandomSpriteEffectSystem
    @State private var spriteScene: SKScene
    
    init(minGrayScale: Float = 0.0, maxGrayScale: Float = 1.0, 
         minAlpha: Float = 0.0, maxAlpha: Float = 1.0) {
        let component = RandomSpriteEffectComponent(
            minGrayScale: minGrayScale,
            maxGrayScale: maxGrayScale,
            minAlpha: minAlpha,
            maxAlpha: maxAlpha
        )
        _system = State(initialValue: RandomSpriteEffectSystem(component: component))
        
        let scene = SKScene(size: CGSize(width: 100, height: 100))
        scene.backgroundColor = .clear
        _spriteScene = State(initialValue: scene)
    }
    
    var body: some View {
        SpriteView(scene: spriteScene)
            .onAppear {
                setupSpriteNode()
            }
            .onChange(of: spriteScene) { _ in
                // Update logic handled in SpriteKit scene update
            }
    }
    
    private func setupSpriteNode() {
        let spriteNode = SKSpriteNode(color: .white, size: CGSize(width: 100, height: 100))
        spriteNode.position = CGPoint(x: spriteScene.size.width / 2, y: spriteScene.size.height / 2)
        spriteScene.addChild(spriteNode)
        
        system.setup(with: spriteNode)
        
        // Set up update loop
        spriteScene.updateHandler = { currentTime, deltaTime in
            system.update(deltaTime: deltaTime)
        }
    }
}