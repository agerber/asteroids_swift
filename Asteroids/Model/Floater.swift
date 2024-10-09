import SpriteKit

class Floater: Sprite {
    
    init(position: CGPoint, gameScene: GameScene) {
        super.init(gameScene: gameScene)
        
        draw()
        
        // Rotate
        let rotateAction = SKAction.rotate(byAngle: spin, duration: 1)
        self.run(SKAction.repeatForever(rotateAction))
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw() {
        let customShape = drawVector()
        self.path = customShape.path
        self.strokeColor = .white
        self.fillColor = customShape.fillColor
        self.lineWidth = customShape.lineWidth
        
        self.position = position
        self.zPosition = 5
        self.name = "power_up"
        
        self.physicsBody = SKPhysicsBody(polygonFrom: customShape.path!)
        self.physicsBody?.categoryBitMask = PhysicsCategory.powerUp
        self.physicsBody?.contactTestBitMask = PhysicsCategory.spaceship
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
        self.physicsBody?.affectedByGravity = false
    }
    
    func drawVector() -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 50))
        path.addLine(to: CGPoint(x: 25, y: 15))
        path.addLine(to: CGPoint(x: 50, y: 0))
        path.addLine(to: CGPoint(x: 25, y: -15))
        path.addLine(to: CGPoint(x: 0, y: -50))
        path.addLine(to: CGPoint(x: -25, y: -15))
        path.addLine(to: CGPoint(x: -50, y: 0))
        path.addLine(to: CGPoint(x: -25, y: 15))
        path.closeSubpath()
        
        let shapeNode = SKShapeNode(path: path)
        shapeNode.strokeColor = .cyan
        shapeNode.fillColor = .clear
        shapeNode.lineWidth = 2.0
        return shapeNode
    }
}
