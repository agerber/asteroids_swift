import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Spaceship
    var spaceship: Spaceship!

    // Bullet array
    var playerBullets: [Bullet] = []
    
    var backgroundStars: [SKShapeNode] = []
    
    // Movement variables
    var isMovingLeft = false
    var isMovingRight = false
    var isRotatingLeft = false
    var isRotatingRight = false
    var isMovingUp = false
    var isMovingDown = false
    
    override init(size: CGSize) {
        super.init(size: size)
        self.scaleMode = .aspectFill
    }
    
    // Required initializer for decoding (used when loading from .sks)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        setupBackground()
        
        physicsWorld.contactDelegate = self
        
        setupSpaceship()
    }
    
    func setupBackground() {
            backgroundColor = SKColor.black
            
            // Clear any existing stars
            backgroundStars.forEach { $0.removeFromParent() }
            backgroundStars.removeAll()
            
            // Number of stars
            let numberOfStars = 100
            
            for _ in 0..<numberOfStars {
                let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
                star.fillColor = SKColor.white
                star.strokeColor = SKColor.white
                let randomX = CGFloat.random(in: 0...size.width)
                let randomY = CGFloat.random(in: 0...size.height)
                star.position = CGPoint(x: randomX, y: randomY)
                star.zPosition = -1
                addChild(star)
                backgroundStars.append(star) // Store reference to the stars
            }
        }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        
        // Reposition stars in the new window size
        for star in backgroundStars {
            let randomX = CGFloat.random(in: 0...size.width)
            let randomY = CGFloat.random(in: 0...size.height)
            star.position = CGPoint(x: randomX, y: randomY)
        }
        
        // Add more stars if needed for larger screens
        if size.width > oldSize.width || size.height > oldSize.height {
            let additionalStars = Int((size.width * size.height) / (oldSize.width * oldSize.height)) * 10
            for _ in 0..<additionalStars {
                let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
                star.fillColor = SKColor.white
                star.strokeColor = SKColor.white
                let randomX = CGFloat.random(in: 0...size.width)
                let randomY = CGFloat.random(in: 0...size.height)
                star.position = CGPoint(x: randomX, y: randomY)
                star.zPosition = -1
                addChild(star)
                backgroundStars.append(star)
            }
        }
    }


    func setupSpaceship() {
        spaceship = Spaceship()
        spaceship.position = CGPoint(x: size.width / 2, y: spaceship.size.height / 2 + 20)
        spaceship.zPosition = 1
        addChild(spaceship)
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
            case 123: // Left Arrow
                isMovingLeft = true
            case 124: // Right Arrow
                isMovingRight = true
            case 0: // 'A' key
                isRotatingLeft = true
            case 2: // 'D' key
                isRotatingRight = true
            case 126: // Up Arrow
                isMovingUp = true
            case 125: // Down Arrow
                isMovingDown = true
            case 49: // Spacebar
                shoot()
            default:
                break
        }
    }
    
    override func keyUp(with event: NSEvent) {
          switch event.keyCode {
          case 123: // Left Arrow
              isMovingLeft = false
          case 124: // Right Arrow
              isMovingRight = false
          case 0: // 'A' key
              isRotatingLeft = false
          case 2: // 'D' key
              isRotatingRight = false
          case 126: // Up Arrow
              isMovingUp = false
          case 125: // Down Arrow
              isMovingDown = false
          default:
              break
          }
      }
    
    func shoot() {
        let bullet = Bullet(spaceship: spaceship)
        bullet.zPosition = 1
        addChild(bullet)
        playerBullets.append(bullet)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Handle spaceship rotation
        if isRotatingLeft {
            spaceship.rotateCounterClockwise()
        }
        if isRotatingRight {
            spaceship.rotateClockwise()
        }
        
        // Handle spaceship movement
        let moveSpeed: CGFloat = 5
        if isMovingLeft {
            spaceship.position.x -= moveSpeed
            if spaceship.position.x < spaceship.size.width / 2 {
                spaceship.position.x = spaceship.size.width / 2
            }
        }
        if isMovingRight {
            spaceship.position.x += moveSpeed
            if spaceship.position.x > size.width - spaceship.size.width / 2 {
                spaceship.position.x = size.width - spaceship.size.width / 2
            }
        }
        if isMovingUp {
            spaceship.position.y += moveSpeed
            if spaceship.position.y > size.height - spaceship.size.height / 2 {
                spaceship.position.y = size.height - spaceship.size.height / 2
            }
        }
        if isMovingDown {
            spaceship.position.y -= moveSpeed
            if spaceship.position.y < spaceship.size.height / 2 {
                spaceship.position.y = spaceship.size.height / 2
            }
        }
        
        // Remove bullets that are off-screen
        playerBullets = playerBullets.filter { bullet in
            if bullet.position.x < 0 || bullet.position.x > size.width || bullet.position.y < 0 || bullet.position.y > size.height {
                bullet.removeFromParent()
                return false
            }
            return true
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // Bullet hits enemy
        if (bodyA.categoryBitMask == 3 && bodyB.categoryBitMask == 2) ||
            (bodyA.categoryBitMask == 2 && bodyB.categoryBitMask == 3) {
            
            if let enemy = bodyA.categoryBitMask == 2 ? bodyA.node as? SKSpriteNode : bodyB.node as? SKSpriteNode,
               let bullet = bodyA.categoryBitMask == PhysicsCategory.bullet ? bodyA.node as? Bullet : bodyB.node as? Bullet {
                
                enemy.removeFromParent()
                bullet.removeFromParent()

                if let bulletIndex = playerBullets.firstIndex(of: bullet) {
                    playerBullets.remove(at: bulletIndex)
                }
            }
        }
    }
}
