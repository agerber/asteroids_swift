import SpriteKit

class ShieldFloater: Floater {
    
    override init(position: CGPoint, gameScene: GameScene) {
        super.init(position: position, gameScene: gameScene)
        
        strokeColor = .cyan
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
