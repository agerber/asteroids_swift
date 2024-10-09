import SpriteKit

class WhiteCloudDebris: SKSpriteNode, Movable {
    init(at position: CGPoint, gameScene: GameScene) {
        let texture = SKTexture(imageNamed: "explosion-1")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.position = position
        
        draw()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func draw() {
        self.zPosition = 10
        self.size = CGSize(width: 100, height: 100)
        
        scene?.addChild(self)
        
        // Load the explosion frames
        var explosionFrames: [SKTexture] = []
        for i in 1...9 {
            let textureName = "explosion-\(i)"
            explosionFrames.append(SKTexture(imageNamed: textureName))
        }
        
        // Create the animation action
        let explosionAction = SKAction.animate(with: explosionFrames, timePerFrame: 0.05) // Adjust time per frame as needed
        let removeAction = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([explosionAction, removeAction])
        
        // Run the animation and remove the sprite after it completes
        self.run(explosionSequence)
    }
    
    func move() {
        
    }
}
