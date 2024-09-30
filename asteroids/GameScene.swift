import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var musicPlayer: AVAudioPlayer?
    var isMusicOn = true
    var isRadarOn = false
    var lifeCount = 2
    var lifeLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var levelLabel: SKLabelNode!
    var score = 0
    var level = 1
    var isGameStarted = false
    var objectSpeed: CGFloat = 3.0  // Starting speed of obstacles
    var isFiring = false  // Track if spacebar is held
    
    override func didMove(to view: SKView) {
        showMenu()
        setupBackgroundMusic()
    }
    
    func setupBackgroundMusic() {
        if let musicURL = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") {
            musicPlayer = try? AVAudioPlayer(contentsOf: musicURL)
            musicPlayer?.play()
            musicPlayer?.numberOfLoops = -1
        }
    }
    
    func showMenu() {
        let menuLabel = SKLabelNode(text: "GAME OVER\nuse the arrow keys to turn and thrust\nuse the space bar to fire\n'S' to start\n'P' to pause\n'Q' to quit\n'M' to toggle music\n'A' to toggle radar")
        menuLabel.numberOfLines = 7
        menuLabel.fontSize = 20
        menuLabel.fontColor = .white
        menuLabel.horizontalAlignmentMode = .center
        menuLabel.verticalAlignmentMode = .center
        menuLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(menuLabel)
    }
    
    func startGame() {
        isGameStarted = true
        removeAllChildren()
        
        setupPlayer()
        setupHUD()
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(spawnObstacle),
                SKAction.wait(forDuration: 1.5)
            ])
        ))
    }
    
    func setupPlayer() {
        player = SKSpriteNode(imageNamed: "Spaceship")
        player.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        player.setScale(0.5)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = 1
        player.physicsBody?.contactTestBitMask = 2
        addChild(player)
    }
    
    func setupHUD() {
        lifeLabel = SKLabelNode(text: "Lives: \(lifeCount)")
        lifeLabel.position = CGPoint(x: frame.minX + 100, y: frame.maxY - 50)
        addChild(lifeLabel)
        
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.position = CGPoint(x: frame.maxX - 100, y: frame.maxY - 50)
        addChild(scoreLabel)
        
        levelLabel = SKLabelNode(text: "Level: \(level)")
        levelLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        addChild(levelLabel)
    }
    
    // Handle key presses
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 126: // Arrow Up
            thrust()
        case 123: // Arrow Left
            player.zRotation += CGFloat.pi / 8
        case 124: // Arrow Right
            player.zRotation -= CGFloat.pi / 8
        case 49: // Spacebar
            isFiring = true
            startFiring() // Start firing continuously
        case 1: // 'S' key
            if !isGameStarted {
                startGame()
            }
        case 35: // 'P' key
            self.isPaused.toggle()
        case 12: // 'Q' key
            exit(0)
        case 46: // 'M' key
            toggleMusic()
        case 0: // 'A' key
            toggleRadar()
        default:
            break
        }
    }
    
    // Handle key release (for stopping continuous fire)
    override func keyUp(with event: NSEvent) {
        if event.keyCode == 49 { // Spacebar released
            isFiring = false
            removeAction(forKey: "continuousFire") // Stop continuous firing
        }
    }
    
    func thrust() {
        // Thrust the spaceship forward based on its current direction
        let dx = cos(player.zRotation) * 50
        let dy = sin(player.zRotation) * 50
        let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.5)
        player.run(moveAction)
        
        // Call wrapping logic after moving
        wrapPlayerPosition()
    }
    
    func wrapPlayerPosition() {
        // If the spaceship moves out of the screen bounds, wrap it to the opposite side
        
        if player.position.x > frame.maxX {
            player.position.x = frame.minX
        } else if player.position.x < frame.minX {
            player.position.x = frame.maxX
        }
        
        if player.position.y > frame.maxY {
            player.position.y = frame.minY
        } else if player.position.y < frame.minY {
            player.position.y = frame.maxY
        }
    }
    
    func fire() {
        let bullet = SKSpriteNode(color: .yellow, size: CGSize(width: 5, height: 20))
        bullet.position = player.position
        bullet.zRotation = player.zRotation
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = 4
        bullet.physicsBody?.contactTestBitMask = 2
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.affectedByGravity = false
        addChild(bullet)
        
        // Calculate the direction and distance for bullet to travel
        let bulletSpeed: CGFloat = 1500 // Speed to ensure it travels far enough
        let dx = cos(bullet.zRotation) * bulletSpeed
        let dy = sin(bullet.zRotation) * bulletSpeed
        
        // Move bullet far enough to clear the screen boundaries
        let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 2.0) // Lasts 2 seconds for long travel
        let removeAction = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    func spawnObstacle() {
        // Create a random number of shrinkable stages (1-3)
        let shrinkStages = Int.random(in: 1...3)
        
        let obstacle = SKSpriteNode(color: .gray, size: CGSize(width: 100, height: 100))
        obstacle.position = CGPoint(x: CGFloat.random(in: frame.minX...frame.maxX), y: frame.maxY)
        obstacle.name = "obstacle-\(shrinkStages)"  // Attach the shrinkable stage info to the name
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = true
        obstacle.physicsBody?.categoryBitMask = 2
        obstacle.physicsBody?.contactTestBitMask = 1 | 4
        addChild(obstacle)
        
        // Move the object randomly, not just in a straight line
        let moveDown = SKAction.move(to: CGPoint(x: CGFloat.random(in: frame.minX...frame.maxX), y: frame.minY), duration: TimeInterval(objectSpeed))
        let remove = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveDown, remove]))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == 1 || contact.bodyB.categoryBitMask == 1 {
            // Player hit an obstacle, lose a life
            lifeCount -= 1
            lifeLabel.text = "Lives: \(lifeCount)"
            if lifeCount <= 0 {
                gameOver()
            }
        } else if contact.bodyA.categoryBitMask == 4 || contact.bodyB.categoryBitMask == 4 {
            // Bullet hit an obstacle
            let obstacle = contact.bodyA.categoryBitMask == 2 ? contact.bodyA.node : contact.bodyB.node
            
            if let obstacleNode = obstacle {
                // Get the shrink stages from the name
                let shrinkStages = Int(obstacleNode.name?.split(separator: "-").last ?? "3") ?? 3
                
                if shrinkStages > 1 {
                    // Shrink the obstacle by 50%
                    obstacleNode.setScale(obstacleNode.xScale * 0.5)
                    
                    // Update the number of remaining shrink stages in the name
                    obstacleNode.name = "obstacle-\(shrinkStages - 1)"
                } else {
                    // If it has no more shrink stages, remove it
                    obstacleNode.removeFromParent()
                    score += 10
                    scoreLabel.text = "Score: \(score)"
                    
                    // Check for level progression
                    if score % 1000 == 0 {
                        levelUp()
                    }
                }
            }
        }
    }
    
    func levelUp() {
        level += 1
        levelLabel.text = "Level: \(level)"
        objectSpeed -= 0.5  // Increase speed of obstacles
    }
    
    func gameOver() {
        let gameOverLabel = SKLabelNode(text: "GAME OVER")
        gameOverLabel.fontSize = 50
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(gameOverLabel)
        
        isPaused = true
    }
    
    func toggleMusic() {
        if isMusicOn {
            musicPlayer?.pause()
        } else {
            musicPlayer?.play()
        }
        isMusicOn.toggle()
    }
    
    func toggleRadar() {
        isRadarOn.toggle()
        // Implement radar toggle logic (optional)
    }
    
    func startFiring() {
        let fireAction = SKAction.run {
            if self.isFiring {
                self.fire()  // Keep firing if spacebar is held down
            }
        }
        
        let delayAction = SKAction.wait(forDuration: 0.1) // Fire every 0.1 seconds
        let fireSequence = SKAction.sequence([fireAction, delayAction])
        let repeatFire = SKAction.repeatForever(fireSequence)
        
        run(repeatFire, withKey: "continuousFire")
    }
}
