import SpriteKit
import AVFoundation

enum TurnState {
    case idle
    case left
    case right
}

enum ImageState {
    case falconInvisible
    case falcon
    case falconThr
    case falconShield
    case falconShieldThr
}

class Falcon: SKSpriteNode, Movable, UserInputDelegate {
    weak var gameScene: GameScene?
    
    static let INITIAL_SPAWN_TIME = 200
    static let MAX_SHIELD = 800
    static let MAX_NUKE = 2400
    
    var rasterMap: [ImageState: SKTexture] = [:]
    var invisible = 0
    var shield = 0
    var nukeMeter = 0
    
    var shieldNode: SKShapeNode?
    var nukeNode: SKShapeNode?
    
    // Thrust on or off
    var isThrusting = false
    var turnState: TurnState = .idle
    
    var lives: Int = 2
    var canReceiveInput: Bool = true
    
    var rotationSpeed: CGFloat = .pi / 60 // Rotation speed in radians per frame (3 degrees per frame)
    let thrustPower: CGFloat = 30 // Adjust thrust power as needed
    
    var sceneSize: CGSize?
    
    init(scene: GameScene) {
        rasterMap[.falconInvisible] = nil
        rasterMap[.falcon] = SKTexture(imageNamed: "falcon")
        rasterMap[.falconThr] = SKTexture(imageNamed: "falcon_thrust")
        rasterMap[.falconShield] = SKTexture(imageNamed: "falcon_SHIELD")
        rasterMap[.falconShieldThr] = SKTexture(imageNamed: "falcon_SHIELD_thrust")
        
        invisible = Falcon.INITIAL_SPAWN_TIME / 5
        shield = Falcon.INITIAL_SPAWN_TIME
        
        super.init(texture: rasterMap[.falcon], color: .clear, size: rasterMap[.falcon]!.size())
        self.name = "player"
        self.sceneSize = scene.size
        self.gameScene = scene
        
        MusicPlayer.shared.playSoundEffect(filename: "shipspawn", gameScene: gameScene!)
        
        // Setup physics body for collision detection
        self.physicsBody = SKPhysicsBody(texture: rasterMap[.falcon]!, size: rasterMap[.falcon]!.size())
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.spaceship
        self.physicsBody?.contactTestBitMask = PhysicsCategory.asteroid | PhysicsCategory.powerUp
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
        self.physicsBody?.allowsRotation = true // Allow the ship to rotate
        self.physicsBody?.affectedByGravity = false // Space physics, no gravity
        self.physicsBody?.linearDamping = 0.5 // Optional: To simulate space friction
        self.physicsBody?.angularDamping = 0.5 // Optional: For smoother rotations
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateSceneSize(scene: GameScene) {
        self.sceneSize = scene.size
    }
    
    func giveNukePower() {
        nukeMeter = Falcon.MAX_NUKE
        
        MusicPlayer.shared.playSoundEffect(filename: "nuke-up", gameScene: self.gameScene!)
    }
    
    func updateNukeMeter() {
        if nukeMeter > 0 {
            gameScene?.updateNukeBar(duration: CGFloat(Falcon.MAX_NUKE), remainingTime: CGFloat(nukeMeter))
        }
        else {
            if (nukeNode != nil) {
                removeNuke()
            }
        }
    }
    
    func removeNuke() {
        nukeNode?.removeFromParent()
        nukeNode = nil
    }
    
    // Reset spaceship's position to center
    func respawn(at position: CGPoint) {
        canReceiveInput = false
        self.physicsBody?.contactTestBitMask = PhysicsCategory.none
        
        disappearForSeconds(1.0) {
            self.position = position // Respawn after 1 second
            self.physicsBody?.contactTestBitMask = PhysicsCategory.asteroid | PhysicsCategory.powerUp
            
            self.canReceiveInput = true
            MusicPlayer.shared.playSoundEffect(filename: "shipspawn", gameScene: self.gameScene!)
        }
    }
    
    func disappearForSeconds(_ seconds: TimeInterval, completion: @escaping () -> Void) {
        self.alpha = 0 // Make invisible
        
        let waitAction = SKAction.wait(forDuration: seconds)
        let reappearAction = SKAction.run {
            self.alpha = 1.0 // Restore visibility
            completion() // Perform respawn after becoming visible
        }
        self.run(SKAction.sequence([waitAction, reappearAction]))
    }
    
    func becomeVulnerable() {
        self.physicsBody?.contactTestBitMask = PhysicsCategory.asteroid // Enable collision again
    }
    
    func giveShield() {
        shield = Falcon.MAX_SHIELD
        
        MusicPlayer.shared.playSoundEffect(filename: "shieldup", gameScene: gameScene!)
    }
    
    func giveInitialShield() {
        shield = Falcon.INITIAL_SPAWN_TIME
    }
    
    func updateShield() {
        if (shield > 0) {
            gameScene?.updateShieldBar(duration: CGFloat(Falcon.MAX_SHIELD), remainingTime: CGFloat(shield))
        }
    }
    
    func drawShieldHalo() {
        if shieldNode == nil {
            let radius = max(self.size.width, self.size.height) / 2 + 10 // Slightly larger than the spaceship
            shieldNode = SKShapeNode(circleOfRadius: radius)
            shieldNode?.strokeColor = SKColor.cyan
            shieldNode?.lineWidth = 3.0
            shieldNode?.glowWidth = 1.0
            shieldNode?.position = CGPoint(x: 0, y: 0)
            shieldNode?.zPosition = -1 // Behind the spaceship
            
            addChild(shieldNode!)
        }
    }
    
    func drawNukeHalo() {
        if nukeNode == nil {
            let radius = max(self.size.width, self.size.height) / 2 // Slightly larger than the spaceship
            nukeNode = SKShapeNode(circleOfRadius: radius)
            nukeNode?.strokeColor = SKColor.yellow
            nukeNode?.lineWidth = 3.0
            nukeNode?.glowWidth = 1.0
            nukeNode?.position = CGPoint(x: 0, y: 0)
            nukeNode?.zPosition = -1 // Behind the spaceship
            
            addChild(nukeNode!)
        }
    }
    
    // Remove the shield from the spaceship
    func removeShield() {
        shieldNode?.removeFromParent()
        shieldNode = nil
    }
    
    // MARK: Movable
    func move() {
        if (invisible > 0) { invisible -= 1 }
        if (shield > 0) {
            updateShield()
            shield -= 1
        }
        if (nukeMeter > 0) {
            updateNukeMeter()
            nukeMeter -= 1
        }
        
        switch turnState {
        case .left:
            self.zRotation += rotationSpeed
        case .right:
            self.zRotation -= rotationSpeed
        case .idle:
            break
        }
        
        // Handle thrust
        if isThrusting {
            let thrustVector = CGVector(dx: thrustPower * cos(zRotation), dy: thrustPower * sin(zRotation))
            self.physicsBody?.applyForce(thrustVector)
            if !isThrusting {
                MusicPlayer.shared.startThrustSound()
            }
            isThrusting = true
        } else {
            if isThrusting {
                MusicPlayer.shared.stopThrustSound()
            }
            isThrusting = false
        }
        
        draw()
        wrapAroundScreen()
    }
    
    func draw() {
        if (nukeMeter > 0) {
            drawNukeHalo()
        }
        else {
            removeNuke()
        }
        
        if invisible > 0 {
            texture = rasterMap[.falconInvisible]
        }
        else if shield > 0 {
            texture = isThrusting ? rasterMap[.falconShieldThr] : rasterMap[.falconShield]
            if (shieldNode == nil) { drawShieldHalo() }
        }
        else {
            texture = isThrusting ? rasterMap[.falconThr] : rasterMap[.falcon]
            removeShield()
        }
    }
    
    func wrapAroundScreen() {
        guard let scene = scene, let camera = scene.camera else { return }
        
        // Calculate the visible area of the screen based on the camera's position and scene size
        let cameraX = camera.position.x
        let cameraY = camera.position.y
        
        let halfWidth = scene.size.width / 2
        let halfHeight = scene.size.height / 2
        
        let minX = cameraX - halfWidth
        let maxX = cameraX + halfWidth
        let minY = cameraY - halfHeight
        let maxY = cameraY + halfHeight
        
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
}
