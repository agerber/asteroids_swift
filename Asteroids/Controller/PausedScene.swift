import SpriteKit

class PausedScene: SKScene, UserInputDelegate {
    
    var userInput: UserInput = UserInput()
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        userInput.delegate = self
        
        // Add "GAME PAUSED" label
        let pausedLabel = SKLabelNode(text: "GAME PAUSED")
        pausedLabel.fontSize = 40
        pausedLabel.fontColor = .white
        pausedLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        pausedLabel.zPosition = 100
        addChild(pausedLabel)
        
        // Add instruction label
        let instructionLabel = SKLabelNode(text: "Press 'P' to continue")
        instructionLabel.fontSize = 24
        instructionLabel.fontColor = .gray
        instructionLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        instructionLabel.zPosition = 100
        addChild(instructionLabel)
    }

    // Handle key press to resume the game
    override func keyDown(with event: NSEvent) {
        userInput.handleKeyDown(event: event)
    }
    
    func togglePause() {
        if let gameScene = self.userData?["gameScene"] as? GameScene {
            let transition = SKTransition.fade(withDuration: 0.5)
            self.view?.presentScene(gameScene, transition: transition)
        }
    }
}
