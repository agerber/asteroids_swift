import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate, UserInputDelegate {    
    // Spaceship
    var falcon: Falcon!
    var lifeIcons: [SKSpriteNode] = []
    
    var scoreLabel: SKLabelNode!
    var universeLabel: SKLabelNode!
    
    var cameraNode: SKCameraNode!
    
    var score: Int = 0 {
        didSet {
            scoreLabel?.text = "Score: \(score)"
        }
    }
    
    var universe: Universe = .freeFly {
        didSet {
            universeLabel?.text = "Level: [\(universe.rawValue)] \(universe.description)"
        }
    }
    
    var shieldBar: SKSpriteNode?
    var nukeBar: SKSpriteNode?

    // Bullet array
    var bulletList: LinkedList<Movable> = LinkedList<Movable>()
    
    var maxStars = 100
    var stars: LinkedList<Movable> = LinkedList<Movable>()

    var asteroidList: LinkedList<Movable> = LinkedList<Movable>()
    var floaterList: LinkedList<Movable> = LinkedList<Movable>()
    
    var userInput: UserInput = UserInput()
    var isGameOver = false
    var isGameInitialized = false
    
    var radar: Minimap?
    
    override init(size: CGSize) {
        super.init(size: size)
        self.scaleMode = .aspectFill
    }
    
    // Required initializer for decoding (used when loading from .sks)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        if !isGameInitialized {
            // Only run setup logic once
            setupGame()
            setupHUD()
            isGameInitialized = true
        }
        // Resume the game if it's coming back from the pause
        self.isPaused = false
    }
    
    // MARK: Set Ups
    func setupGame() {
        backgroundColor = SKColor.black
        
        physicsWorld.contactDelegate = self
        
        setupSpaceship()
        spawnAsteroid()
        generateStarField()
   
        // Initialize the user input handler
        userInput = UserInput()
        userInput.delegate = self
    }
    
    func generateStarField() {
        stars.clear()
        
        let numberOfStars = isFalconPositionFixed() ? 1000 : 100
        var size = CGSize(width: 1280, height: 720)
        if isFalconPositionFixed() {
            size.width *= 10
            size.height *= 10
        }
        
        for _ in 0..<numberOfStars {
            let star = Star(size: size) // Create a star using the Star class
            star.addToGame(list: stars, gameScene: self)
        }
    }
    
    func setupHUD() {
        setupCamera()
        displayLives()
        setupShieldBar()
        setupNukeBar()
        setupRadar()
        setupScore()
    }
    
    func setupScore() {
        // Create and configure the score label
        scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        // Position in the top-right corner of the camera
        scoreLabel.position = CGPoint(x: cameraNode.frame.width + 600, y: 300)
        scoreLabel.horizontalAlignmentMode = .right // Align the text to the right
        scoreLabel.zPosition = 100
        scoreLabel.text = "Score: \(score)" // Initial score text
        cameraNode.addChild(scoreLabel)
    }
    
    func setupLevel() {
        // Create and configure the level label
        universeLabel = SKLabelNode(fontNamed: "Arial")
        universeLabel.fontSize = 24
        universeLabel.fontColor = .white
        // Position directly below the score label, in the top-right corner of the camera
        universeLabel.position = CGPoint(x: cameraNode!.frame.width + 600, y: 330)
        universeLabel.horizontalAlignmentMode = .right // Align the text to the right
        universeLabel.zPosition = 100
        universeLabel.text = "Level: [\(universe.rawValue)] \(universe.description)"
        cameraNode?.addChild(universeLabel)
    }
    
    func togglePause() {
       // Create the paused scene
       let pausedScene = PausedScene(size: self.size)
       pausedScene.userData = NSMutableDictionary()
       pausedScene.userData?["gameScene"] = self // Pass the current GameScene to the paused scene
       
       // Transition to the paused scene
       let transition = SKTransition.fade(withDuration: 0.5)
       self.view?.presentScene(pausedScene, transition: transition)
       
       // Pause game logic (e.g., stop movement, animations, etc.)
       self.isPaused = true
   }
    
    func setupRadar() {
        let radarSize = CGSize(width: 250, height: 150) // Set radar size
        
        // Set the position relative to the camera, placing it in the top-left corner
        radar = Minimap(minimapSize: radarSize, gameScene: self, camera: cameraNode)
        
        // Add radar to the camera node so it stays static
        cameraNode.addChild(radar!)
    }
    
    func toggleRadar() {
        radar?.toggleRadarVisibility()
    }
    
    func setupCamera() {
        // Create a new SKCameraNode
        cameraNode = SKCameraNode()
        camera = cameraNode
        
        // Position the camera in the center of the scene
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        // Add the camera to the scene
        addChild(cameraNode)
    }
    
    func setupShieldBar() {
        // Create the shield bar background (optional)
        let shieldBarBackground = SKSpriteNode(color: .darkGray, size: CGSize(width: 150, height: 20))
        shieldBarBackground.position = CGPoint(x: size.width / 2 - 400, y: -size.height / 2 + 50) // Bottom-left corner relative to the camera
        shieldBarBackground.anchorPoint = CGPoint(x: 0, y: 0.5) // Anchor to the left
        shieldBarBackground.zPosition = 50 // Ensure it appears on top of other elements
        cameraNode.addChild(shieldBarBackground) // Add to camera node
        
        // Create the actual shield bar (cyan color for example)
        shieldBar = SKSpriteNode(color: .cyan, size: CGSize(width: 150, height: 20))
        shieldBar?.position = CGPoint(x: size.width / 2 - 400, y: -size.height / 2 + 50) // Same position as the background
        shieldBar?.anchorPoint = CGPoint(x: 0, y: 0.5) // Anchor to the left so it decreases in size from right to left
        shieldBar?.zPosition = 51 // Ensure it's above the background
        cameraNode.addChild(shieldBar!) // Add to camera node
    }
    
    func updateShieldBar(duration: CGFloat, remainingTime: CGFloat) {
        // Calculate the new width of the shield bar based on remaining time
        let maxWidth: CGFloat = 150.0
        let newWidth = maxWidth * CGFloat(remainingTime / duration)
        
        shieldBar?.size.width = newWidth
    }
    
    func setupNukeBar() {
        // Create the nuke bar background (optional)
        let nukeBarBackground = SKSpriteNode(color: .darkGray, size: CGSize(width: 150, height: 20))
        nukeBarBackground.position = CGPoint(x: size.width / 2 - 400, y: -size.height / 2 + 80) // Bottom-left corner relative to the camera
        nukeBarBackground.anchorPoint = CGPoint(x: 0, y: 0.5) // Anchor to the left
        nukeBarBackground.zPosition = 50 // Ensure it's on top of other elements
        cameraNode.addChild(nukeBarBackground)

        // Create the actual nuke bar (yellow color)
        nukeBar = SKSpriteNode(color: .yellow, size: CGSize(width: 0, height: 20))
        nukeBar?.position = CGPoint(x: size.width / 2 - 400, y: -size.height / 2 + 80) // Same position as the background
        nukeBar?.anchorPoint = CGPoint(x: 0, y: 0.5) // Anchor to the left so it decreases in size
        nukeBar?.zPosition = 51
        cameraNode.addChild(nukeBar!)
    }

    func updateNukeBar(duration: CGFloat, remainingTime: CGFloat) {
       // Calculate the new width of the nuke bar based on the remaining time
       let maxWidth: CGFloat = 150.0
       let newWidth = maxWidth * CGFloat(remainingTime / duration)
       nukeBar?.size.width = newWidth
   }
    
    // Reset the nuke bar (e.g., when the nuke is used or expired)
    func resetNukeBar() {
        falcon.removeNuke()
        updateNukeBar(duration: 30, remainingTime: 0) // Set bar width to 0 when reset
        falcon.removeAction(forKey: "nukeCountdown")
    }

    func setupSpaceship() {
        falcon = Falcon(scene: self)
        falcon.lives = 3
        falcon.position = CGPoint(x: size.width / 2, y: falcon.size.height / 2 + 20)
        falcon.zPosition = 1
        addChild(falcon)
    }
    
    func displayLives() {
        // First, remove any existing life icons to avoid duplication
        for icon in lifeIcons {
            icon.removeFromParent()
        }
        lifeIcons.removeAll()

        let lifeCount = falcon.lives - 1
        let iconSize = CGSize(width: 50, height: 50) // Size of each icon
        let padding: CGFloat = 10 // Space between icons

        // Calculate starting X position relative to the bottom-right corner of the camera's view
        let startX = size.width / 2 - CGFloat(lifeCount) * (iconSize.width + padding) - padding
        let startY = -size.height / 2 + iconSize.height / 2 + padding + 30 // Bottom-right corner
        
        for i in 0..<lifeCount {
            let lifeIcon = SKSpriteNode(imageNamed: "life")
            lifeIcon.size = iconSize
            lifeIcon.position = CGPoint(x: startX + CGFloat(i) * (iconSize.width + padding), y: startY)
            lifeIcon.zPosition = 100 // Ensure it's on top of other UI elements
            cameraNode.addChild(lifeIcon) // Add to camera node to keep it static on screen
            lifeIcons.append(lifeIcon)
        }
    }
    
    func isFalconPositionFixed() -> Bool {
        return universe != .freeFly
    }
    
    // MARK: Levels
    func advanceToNextLevel() {
        universe = universe.nextUniverse()
        
        // Re-center the spaceship
        falcon.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        score += 10000
        
        generateStarField()
        
        // Spawn more asteroids or update game objects for the next level
        let asteroidCount: Int
        
        switch universe {
        case .center:
            asteroidCount = 2
        case .big:
            asteroidCount = 3
        case .horizontal:
            asteroidCount = 2
        case .vertical:
            asteroidCount = 3
        case .dark:
            asteroidCount = 1
            hideGameObjectsForDarkMode()
            falcon.isHidden = true
            radar?.isHidden = true
        default:
            asteroidCount = 1
        }
        
        for _ in 0..<asteroidCount {
            spawnAsteroid()
        }
    }
    
    // MARK: Spawn
    func spawnAsteroid() {
        let asteroid = Asteroid(gameScene: self, sizeLevel: 1)
        asteroid.position = CGPoint(x: self.size.width + 50, y: CGFloat.random(in: 0...self.size.height))
        asteroid.zPosition = 1
        asteroid.addToGame(list: asteroidList, gameScene: self)
    }
    
    func spawnPowerUp() {
        let floaterPosition = CGPoint(x: CGFloat.random(in: 0...size.width), y: CGFloat.random(in: 0...size.height))
        
        // 40% chance for nuke power-up
        let isNukePowerUp = Int.random(in: 0...100) < 40
        let floater = isNukePowerUp ? NukeFloater(position: floaterPosition, gameScene: self) : ShieldFloater(position: floaterPosition, gameScene: self)
        
        floater.addToGame(list: floaterList, gameScene: self)
    }
    
    // MARK: User Input
    override func keyDown(with event: NSEvent) {
        guard falcon.canReceiveInput else { return }
        
        if let key = KeyCode(rawValue: Int(event.keyCode)) {
            switch key {
            case .up:
                falcon.isThrusting = true
            case .left:
                falcon.turnState = .left
            case .right:
                falcon.turnState = .right
                
            default:
                userInput.handleKeyDown(event: event)
            }
        }
    }
    
    override func keyUp(with event: NSEvent) {
        if let key = KeyCode(rawValue: Int(event.keyCode)) {
            switch key {
            case .up:
                falcon.isThrusting = false
            case .left, .right:
                falcon.turnState = .idle
            default:
                userInput.handleKeyUp(event: event)
            }
        }
    }
    
    // MARK: UserInputDelegate
    func shoot() {
        let bullet = Bullet(falcon: falcon)
        bullet.zPosition = 1
        bullet.addToGame(list: bulletList, gameScene: self)
        
        MusicPlayer.shared.playSoundEffect(filename: "thump.wav", gameScene: self)
    }
    
    // MARK: Spaceship
    func fireNuke() {
        if falcon.nukeMeter <= 0 { return }
        resetNukeBar()
        falcon.nukeMeter = 0
        
        MusicPlayer.shared.playSoundEffect(filename: "nuke", gameScene: self)
        
        // Create the nuke as a circle with yellow stroke and clear fill
        let nuke = SKShapeNode(circleOfRadius: 10)
        nuke.position = falcon.position
        
        // Set the fill to clear and stroke to yellow
        nuke.fillColor = .clear // Transparent fill
        nuke.strokeColor = .yellow // Yellow stroke
        nuke.lineWidth = 2 // Adjust the stroke width as needed
        nuke.glowWidth = 0
        
        nuke.zPosition = 10

        // Set up the nuke's physics body to detect collisions
        nuke.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        nuke.physicsBody?.isDynamic = true
        nuke.physicsBody?.categoryBitMask = PhysicsCategory.nuke
        nuke.physicsBody?.contactTestBitMask = PhysicsCategory.asteroid
        nuke.physicsBody?.collisionBitMask = PhysicsCategory.none
        nuke.physicsBody?.affectedByGravity = false

        // Add the nuke to the scene
        addChild(nuke)

        // Action to enlarge the nuke over time
        let enlargeAction = SKAction.scale(by: 50, duration: 3.0)
        let removeNuke = SKAction.removeFromParent()

        // Sequence to enlarge the nuke and then remove it
        nuke.run(SKAction.sequence([enlargeAction, removeNuke]))
    }
    
    func updateStars() {
        guard let camera = camera else { return }

        // Define the visible area of the camera
        let halfWidth = size.width / 2 / camera.xScale
        let halfHeight = size.height / 2 / camera.yScale
        
        let minX = camera.position.x - halfWidth
        let maxX = camera.position.x + halfWidth
        let minY = camera.position.y - halfHeight
        let maxY = camera.position.y + halfHeight
            
        var starsToRemove: [Star] = []
        
        // First pass: Use forEach to identify stars that are out of bounds
        stars.forEach { movable in
            if let star = movable as? Star {
                if star.position.x < minX || star.position.x > maxX || star.position.y < minY || star.position.y > maxY {
                    starsToRemove.append(star)
                }
            }
        }

        // Second pass: Remove the stars from the game and the LinkedList
        starsToRemove.forEach { star in
            star.removeFromGame(list: stars)
        }
    }
    
    func createStar(at position: CGPoint? = nil) -> SKShapeNode {
        let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
        star.fillColor = SKColor.white
        star.strokeColor = SKColor.white
        star.alpha = CGFloat.random(in: 0.3...0.8)
        star.zPosition = -1

        // If no position is provided, generate a random position
        if let position = position {
            star.position = position
        } else {
            let randomX = CGFloat.random(in: 0...size.width)
            let randomY = CGFloat.random(in: 0...size.height)
            star.position = CGPoint(x: randomX, y: randomY)
        }

        return star
    }


    // MARK: Update game states
    override func update(_ currentTime: TimeInterval) {
        // Handle movement
        falcon.move()
        
        asteroidList.forEach { $0.move() }
        floaterList.forEach { $0.move() }
        
        updateStars()
        
        if isFalconPositionFixed() {
            cameraNode.position = falcon.position
        }
        else if universe == .dark {
            hideGameObjectsForDarkMode()
        }
        
        var bulletsToRemove: [Bullet] = []

        bulletList.forEach { bullet in
            guard let camera = camera else { return }

            // Calculate the visible area of the screen based on the camera's position and scene size
            let cameraX = camera.position.x
            let cameraY = camera.position.y
            
            let halfWidth = size.width / 2
            let halfHeight = size.height / 2
            
            let minX = cameraX - halfWidth
            let maxX = cameraX + halfWidth
            let minY = cameraY - halfHeight
            let maxY = cameraY + halfHeight
            
            // Check if the bullet is outside the camera's visible area
            if let bullet = bullet as? Bullet {
                if bullet.position.x < minX || bullet.position.x > maxX || bullet.position.y < minY || bullet.position.y > maxY {
                    bullet.removeFromGame(list: bulletList)
                }
            }
        }
        
        if Int.random(in: 0...10000) < 5 { // ~0.05% chance to spawn every frame
            spawnPowerUp()
        }
        
        radar?.updateMinimap()
    }
    
    func gameOver() {
        isGameInitialized = false
        isGameOver = true
        if let view = self.view {
            let gameOverScene = GameOverScene(size: self.size)
            view.presentScene(gameOverScene)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // Handle collision between asteroid and bullet
        if let asteroid = bodyA.node as? Asteroid, bodyB.categoryBitMask == PhysicsCategory.bullet { // Assuming 1 is bullet's bitmask
            breakAsteroid(asteroid)
            
            if let bullet = bodyB.node as? Bullet {
                bullet.removeFromGame(list: bulletList)
            }
        } else if let asteroid = bodyB.node as? Asteroid, bodyA.categoryBitMask == PhysicsCategory.bullet {
            breakAsteroid(asteroid)
            
            if let bullet = bodyA.node as? Bullet {
                bullet.removeFromGame(list: bulletList)
            }
        }
        
        // Collision between spaceship and asteroid
        if let _ = bodyA.node as? Falcon, bodyB.categoryBitMask == PhysicsCategory.asteroid {
            
            if falcon.shield == 0 {
                spaceshipCollided()
            }
            
            if let asteroid = bodyB.node as? Asteroid {
                breakAsteroid(asteroid)
            }
        }
        
        // Collision between power up and spaceship
        if let _ = bodyA.node as? Falcon, bodyB.categoryBitMask == PhysicsCategory.powerUp {
            if let floter = bodyB.node as? Floater {
                collectPowerUp(floter)
            }
        } else if let _ = bodyB.node as? Falcon, bodyA.categoryBitMask == PhysicsCategory.powerUp {
            if let floater = bodyA.node as? Floater {
                collectPowerUp(floater)
            }
        }
        
        // Detect collision between nuke and asteroid
        if bodyA.categoryBitMask == PhysicsCategory.nuke && bodyB.categoryBitMask == PhysicsCategory.asteroid {
            if let asteroid = bodyB.node as? Asteroid {
                breakAsteroid(asteroid)
            }
        } else if bodyB.categoryBitMask == PhysicsCategory.nuke && bodyA.categoryBitMask == PhysicsCategory.asteroid {
            if let asteroid = bodyA.node as? Asteroid {
                breakAsteroid(asteroid)
            }
        }
    }
    
    func collectPowerUp(_ floater: Floater) {
        if floater is NukeFloater {
            falcon.giveNukePower()
        }
        else {
            falcon.giveShield()
        }
        
        floater.removeFromGame(list: floaterList)
    }
    
    func spaceshipCollided() {
        // Reduce spaceship's lives
        falcon.lives -= 1
        
        if falcon.lives > 0 {
            // Respawn spaceship in the middle of the screen
            falcon.respawn(at: CGPoint(x: size.width / 2, y: falcon.size.height / 2 + 20))
            falcon.giveInitialShield()
            falcon.zPosition = 1
            displayLives()
        } else {
            // Game over if all lives are lost
            gameOver()
        }
    }
    
    func breakAsteroid(_ asteroid: Asteroid) {
        let newAsteroids = asteroid.breakApart() // Break into smaller asteroids
        for newAsteroid in newAsteroids {
            newAsteroid.addToGame(list: asteroidList, gameScene: self)
        }
        
        // Increase the score
        score += 10 * asteroid.sizeLevel
        
        asteroid.removeFromGame(list: asteroidList)
        
        if asteroidList.length == 0 {
            if universe == .dark {
                gameOver()
            }
            else {
                advanceToNextLevel()
            }
        }
        
        let soundName: String
        if (asteroid.sizeLevel < 3) {
            soundName = "kapow.wav"
        }
        else {
            soundName = "pillow.wav"
            asteroid.explode()
        }
        
        MusicPlayer.shared.playSoundEffect(filename: soundName, gameScene: self)
    }
    
    
    func hideGameObjectsForDarkMode() {
        // Hide all power-ups
        floaterList.forEach { floater in
            (floater as? Floater)!.isHidden = true
        }
        
        bulletList.forEach { bullet in
            (bullet as? Bullet)!.isHidden = true
        }

        // Hide all asteroids
        asteroidList.forEach { asteroid in
            (asteroid as? Asteroid)!.isHidden = true
        }
        
        
        falcon.isHidden = true
    }
}
