import SpriteKit

class Asteroid: Sprite {
    let LARGE_RADIUS: CGFloat = 100
    var sizeLevel: Int = 1
    
    init(gameScene: GameScene, sizeLevel: Int = 1) {
        super.init(gameScene: gameScene)
        self.sizeLevel = sizeLevel
        initializeFromSize(sizeLevel: sizeLevel)
        
        // Rotate
        let rotateAction = SKAction.rotate(byAngle: spin, duration: 1)
        self.run(SKAction.repeatForever(rotateAction))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Private method to initialize asteroid's properties
    private func initializeFromSize(sizeLevel: Int) {
        draw()
    }
    
    override func draw() {
        let radius: CGFloat = (sizeLevel == 1) ? LARGE_RADIUS : (sizeLevel == 2 ? LARGE_RADIUS / 2 : LARGE_RADIUS / 4)
        
        // Set the asteroid shape (randomized vertices)
        let asteroidPath = generateVector(radius: radius)
        self.path = asteroidPath
        
        self.strokeColor = .white
        self.fillColor = .black
        self.lineWidth = 1
        
        // Set up the physics body
        self.physicsBody = SKPhysicsBody(polygonFrom: asteroidPath)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.asteroid
        self.physicsBody?.contactTestBitMask = PhysicsCategory.bullet
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    private func generateVector(radius: CGFloat) -> CGPath {
        // Generate the jagged asteroid shape
        let path = CGMutablePath()
        let numberOfSides = Int.random(in: 8...12)
        var firstPoint: CGPoint?
        
        for i in 0..<numberOfSides {
            let angle = CGFloat(i) * (2.0 * .pi / CGFloat(numberOfSides))
            let distance = radius * CGFloat.random(in: 0.75...1.25)
            let x = cos(angle) * distance
            let y = sin(angle) * distance
            let point = CGPoint(x: x, y: y)
            
            if i == 0 {
                path.move(to: point)
                firstPoint = point
            } else {
                path.addLine(to: point)
            }
        }
        
        if let firstPoint = firstPoint {
            path.addLine(to: firstPoint)
        }
        
        return path
    }
    
    // Breaking the asteroid into smaller pieces
    func breakApart() -> [Asteroid] {
        var smallerAsteroids: [Asteroid] = []
        if sizeLevel < 3 {
            let newSizeLevel = sizeLevel + 1
            for _ in 0..<3 {
                let smallerAsteroid = Asteroid(gameScene: self.scene as! GameScene, sizeLevel: newSizeLevel)
                smallerAsteroid.position = self.position
                smallerAsteroids.append(smallerAsteroid)
            }
        }
        return smallerAsteroids
    }
    
    func explode() {
        guard let gameScene = self.gameScene else { return }
        gameScene.addChild(WhiteCloudDebris(at: self.position, gameScene: gameScene))
                    
        // Remove the asteroid after showing the explosion
        self.removeFromParent()
    }
}


