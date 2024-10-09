import SpriteKit

class NukeFloater: Floater {
    
    override init(position: CGPoint, gameScene: GameScene) {
        super.init(position: position, gameScene: gameScene)
        
        strokeColor = .yellow
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
