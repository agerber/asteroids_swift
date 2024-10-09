import SpriteKit

class Star: SKShapeNode, Movable {
    let size: CGSize
    
    init(size: CGSize) {
        self.size = size
        super.init()
        
        let radius = CGFloat.random(in: 1...3)
        let path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
        self.path = path
        
        draw()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func draw() {
        fillColor = SKColor.white
        strokeColor = SKColor.white
        let randomX = CGFloat.random(in: 0...size.width)
        let randomY = CGFloat.random(in: 0...size.height)
        position = CGPoint(x: randomX, y: randomY)
        zPosition = -1
        alpha = CGFloat.random(in: 0.3...0.7)
    }
    
    func move() {
        
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
