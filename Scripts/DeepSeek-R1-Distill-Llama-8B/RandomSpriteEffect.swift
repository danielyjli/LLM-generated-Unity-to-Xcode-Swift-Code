using Foundation

struct RandomSpriteEffectSystem: System {
    private var spriteRenderer: SpriteRenderer
    private var targetGrayScale: Float
    private var targetAlpha: Float
    private var transitionSpeed = 0.5
    private var minGrayScale = 0.0
    private var maxGrayScale = 1.0
    private var minAlpha = 0.0
    private var maxAlpha = 1.0
    
    func initialize() {
        spriteRenderer = getComponent(of: SpriteRenderer.self)
        targetGrayScale = Random.float between minGrayScale and maxGrayScale
        targetAlpha = Random.float between minAlpha and maxAlpha
        triggerEffect()
    }
    
    func update() {
        let currentGrayScale = spriteRenderer.color.gray
        let currentAlpha = spriteRenderer.color.alpha
        
        if abs(currentGrayScale - targetGrayScale) > 0.01 || abs(currentAlpha - targetAlpha) > 0.01 {
            // 平滑过渡到目标颜色
            let targetColor = Color(gray: targetGrayScale, alpha: targetAlpha)
            let delta = transitionSpeed * Time.deltaTime
            let newColor = Color.lerp(spriteRenderer.color, targetColor, delta)
            spriteRenderer.color = newColor
        } else {
            // 达到目标颜色后，随机生成新的目标颜色
            targetGrayScale = Random.float between minGrayScale and maxGrayScale
            targetAlpha = Random.float between minAlpha and maxAlpha
            triggerEffect()
        }
    }
    
    private func triggerEffect() {
        // 这里可以添加一些初始效果触发的逻辑
    }
}

struct RandomSpriteEffectComponent: Component {
    let system: RandomSpriteEffectSystem
    
    func onInput(_ input: Input) {
        // 输入处理逻辑（根据平台选择）
        switch input {
        case .macOS(let gestures):
            // macOS 下的输入处理（如手势）
            break
        case .iOS(let touches):
            // iOS 下的输入处理（如触摸）
            break
        case .visionOS(let gaze):
            // VisionOS 下的输入处理（如视觉输入）
            break
        default:
            break
        }
    }
}