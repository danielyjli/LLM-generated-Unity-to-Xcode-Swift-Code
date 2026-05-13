using SpriteKit
using Foundation

@available(iOS, macOS)
class Ball : Component {
    @IBOutlet var position: Vector2 {
        get { return transform.position; }
        set { transform.position = $0; }
    }
    
    public var antiGravityForce = 10.0f
    public var decelerationAmount = 5.0f
    public var initialSpeed = 2.0f
    public var minForce = 1.0f
    public var maxForce = 2.0f
    private var rb: Rigidbody2D = nil
    private var isInAntiGravityField = false
    private var moveLeft = false
    
    private var direction = Vector2.zero
    private var currentVelocity = Vector2.zero
    
    public func spawnSplitBall() {
        let splitBall1 = Instantiate(splitBallPrefab, position, identityTransform)
        let splitBall2 = Instantiate(splitBallPrefab, position, identityTransform)
    }
    
    override init() {
        super.init()
        rb = getComponent(Rigidbody2D.self)
        // Random angle
        let angle = Random.float(in: 0..<2¦Ð)
        // Direction vector
        direction = Vector2(x: cos(angle), y: sin(angle))
        // Initial speed
        rb.velocity = direction.normalized * initialSpeed
    }
    
    override func update(_ delta: Float) {
        if isInAntiGravityField {
            // Apply anti gravity force
            rb.velocity -= Vector2(up: 1.0f) * rb.velocity * antiGravityForce * delta
        }
        
        // Apply deceleration if in deceleration zone
        if isInAntiGravityField {
            let normalizedVelocity = rb.velocity.normalized
            if normalizedVelocity != Vector2.zero {
                rb.velocity = rb.velocity - normalizedVelocity * decelerationAmount * delta
            }
        }
        
        // Handle collisions
        handleCollision()
    }
    
    private func handleCollision() {
        if let collision = rb.collisionBody?.collision {
            moveLeft = Random.float(in: 0..<1) < 0.5
            // Generate random force
            let force = Random.float(in: minForce..., maxForce...)
            let direction = moveLeft ? -1.0f : 1.0f
            rb.AddForce(Vector2(x: direction * force, y: 0.0f), forceMode: .impulse)
        }
    }
    
    override func willTrigger(_ other: Collision) {
        if other.CompareTag("AntiGravityField") {
            isInAntiGravityField = true
        } else if other.CompareTag("Deceleration") {
            // Apply deceleration
            let normalizedVelocity = rb.velocity.normalized
            if normalizedVelocity != Vector2.zero {
                rb.velocity = rb.velocity - normalizedVelocity * decelerationAmount
            }
        } else if other.CompareTag("Death") {
            Destroy(gameObject)
        }
    }
    
    override func didExit(_ other: Collision) {
        if other.CompareTag("AntiGravityField") {
            isInAntiGravityField = false
        }
    }
}