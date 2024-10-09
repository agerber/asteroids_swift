import SpriteKit

class GameOverScene: SKScene, UserInputDelegate {
    
    var userInput: UserInput = UserInput()
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        showGameOverText()
        
        userInput.delegate = self
    }
    
    // Function to display the game-over message
    func showGameOverText() {
        let gameOverLabel = SKLabelNode(text: "GAME OVER")
        gameOverLabel.fontSize = 40
        gameOverLabel.fontName = "HelveticaNeue"
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 200)
        addChild(gameOverLabel)
        
        let instructionText = """
            use the arrow keys to turn and thrust
            use the space bar to fire
            'S' to start
            'P' to pause
            'Q' to quit
            'M' to toggle music
            'A' to toggle radar
        """
        let instructionsLabel = SKLabelNode(text: instructionText)
        instructionsLabel.fontSize = 20
        instructionsLabel.fontName = "HelveticaNeue"
        instructionsLabel.fontColor = SKColor.white
        instructionsLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        instructionsLabel.numberOfLines = 0
        instructionsLabel.preferredMaxLayoutWidth = size.width - 40 // Adjust to fit the screen
        instructionsLabel.horizontalAlignmentMode = .center
        addChild(instructionsLabel)
    }
    
    // Detect when the 'S' key is pressed to start the game
    override func keyDown(with event: NSEvent) {
        userInput.handleKeyDown(event: event)
    }
    
    // Function to start the game and transition to the main game scene
    func startGame() {
        if let view = self.view {
            let transition = SKTransition.fade(withDuration: 1.0)
            let gameScene = GameScene(size: self.size)
            view.presentScene(gameScene, transition: transition)
        }
    }

}
