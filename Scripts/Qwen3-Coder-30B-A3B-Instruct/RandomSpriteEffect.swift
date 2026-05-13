import SwiftUI
import SpriteKit

// MARK: - Component Data
struct RandomSpriteEffectComponent {
    var minGrayScale: Float = 0.0
    var maxGrayScale: Float = 1.0
    var minAlpha: Float = 0.0
    var maxAlpha: Float = 1.0
    var transitionSpeed: Float = 0.5
}

// MARK: - System Logic
class RandomSpriteEffectSystem: SKNode {
    private var component: RandomSpriteEffectComponent
    private var targetGrayScale: Float = 0.0
    private var targetAlpha: Float = 0.0
    
    init(component: RandomSpriteEffectComponent) {
        self.component = component
        super.init()
        randomizeSpriteEffect()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // [Positive Transfer] Start equivalent - initialization
    func setup() {
        randomizeSpriteEffect()
    }
    
    // [Positive Transfer] Update equivalent - per-frame logic
    func update(deltaTime: TimeInterval) {
        guard let spriteNode = self as? SKSpriteNode else { return }
        
        let currentGrayscale = spriteNode.color.grayscale
        let currentAlpha = spriteNode.color.alpha
        
        if abs(currentGrayscale - targetGrayScale) > 0.01 ||
           abs(currentAlpha - targetAlpha) > 0.01 {
            // Perform smooth transition
            let targetColor = UIColor(
                red: CGFloat(targetGrayScale),
                green: CGFloat(targetGrayScale),
                blue: CGFloat(targetGrayScale),
                alpha: CGFloat(targetAlpha)
            )
            
            let interpolatedColor = UIColor.interpolate(
                from: spriteNode.color,
                to: targetColor,
                factor: Float(component.transitionSpeed * Float(deltaTime))
            )
            
            spriteNode.color = interpolatedColor
        } else {
            // Reached target color, generate new random target
            randomizeSpriteEffect()
        }
    }
    
    // [Positive Transfer] RandomizeSpriteEffect equivalent
    private func randomizeSpriteEffect() {
        targetGrayScale = Float.random(in: component.minGrayScale...component.maxGrayScale)
        targetAlpha = Float.random(in: component.minAlpha...component.maxAlpha)
    }
}

// MARK: - UIColor Extension for Interpolation
extension UIColor {
    static func interpolate(from startColor: UIColor, to endColor: UIColor, factor: Float) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        startColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        endColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let interpolatedR = r1 + (r2 - r1) * CGFloat(factor)
        let interpolatedG = g1 + (g2 - g1) * CGFloat(factor)
        let interpolatedB = b1 + (b2 - b1) * CGFloat(factor)
        let interpolatedA = a1 + (a2 - a1) * CGFloat(factor)
        
        return UIColor(red: interpolatedR, green: interpolatedG, blue: interpolatedB, alpha: interpolatedA)
    }
    
    var grayscale: Float {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return Float(0.299 * r + 0.587 * g + 0.114 * b)
    }
}