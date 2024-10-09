import SpriteKit

class Sprite: SKShapeNode, Movable {
    var spin: CGFloat = 0.0
    var deltaX: CGFloat = 0.0
    var deltaY: CGFloat = 0.0
    var sceneSize: CGSize?
    var gameScene: GameScene?
    
    init(gameScene: GameScene) {
        super.init()
        self.spin = somePosNegValue(10)
        self.deltaX = somePosNegValue(200)
        self.deltaY = somePosNegValue(200)
        self.sceneSize = gameScene.size
        self.gameScene = gameScene
        
        // Movement
        let moveAction = SKAction.moveBy(x: deltaX, y: deltaY, duration: 1)
        let repeatAction = SKAction.repeatForever(moveAction)
        self.run(repeatAction)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func somePosNegValue(_ max: Int) -> CGFloat {
        let sign = Bool.random() ? 1 : -1
        return CGFloat.random(in: 0...CGFloat(max)) * CGFloat(sign)
    }
    
    func move() {
        guard let scene = scene, let camera = scene.camera else { return }
        
        // Calculate the visible area of the screen based on the camera's position and scene size
        let cameraX = camera.position.x
        let cameraY = camera.position.y
        
        let halfWidth = scene.size.width / 2
        let halfHeight = scene.size.height / 2
        
        let minX = cameraX - halfWidth
        var maxX = cameraX + halfWidth
        var minY = cameraY - halfHeight
        let maxY = cameraY + halfHeight
        
        switch gameScene?.universe {
        case .big, .dark:
            maxX = cameraX + halfWidth * 3
            minY = cameraY - halfHeight * 3
        case .horizontal:
            maxX = cameraX + halfWidth * 3
            minY = cameraY - halfHeight
        case .vertical:
            maxX = cameraX + halfWidth
            minY = cameraY - halfHeight * 3
        default:
            print("Level")
        }
        
        // Wrap the asteroid around the visible area
        if position.x < minX {
            position.x = maxX
        } else if position.x > maxX {
            position.x = minX
        }
        
        if position.y < minY {
            position.y = maxY
        } else if position.y > maxY {
            position.y = minY
        }
    }
    
    func draw() {
        
    }
    
    func addToGame(list: LinkedList<Movable>, gameScene: GameScene) {
        list.add(self)
        gameScene.addChild(self)
    }
    
    func removeFromGame(list: LinkedList<any Movable>) {
        // Loop through and remove the matching object by reference
        list.remove(self as any Movable)
        self.removeFromParent()
    }
}
