import SpriteKit

class Minimap: SKNode {
    
    var minimapBackground: SKShapeNode? // Background for the radar (window-like)
    var outerMinimapBackground: SKShapeNode?
    var minimapSize: CGSize
    var isRadarVisible: Bool = true
    
    var gameScene: GameScene
    var camera: SKCameraNode
    
    init(minimapSize: CGSize, gameScene: GameScene, camera: SKCameraNode) {
        self.minimapSize = minimapSize
        self.gameScene = gameScene
        self.camera = camera
        super.init()
        
        setupRadar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupRadar() {
        // Create the radar background
        minimapBackground = SKShapeNode(rectOf: minimapSize)
        minimapBackground?.position = CGPoint(x: camera.frame.width - 495, y: 275)
        minimapBackground?.fillColor = .black
        minimapBackground?.strokeColor = .white
        minimapBackground?.lineWidth = 1
        minimapBackground?.zPosition = -1 // Ensure it's on top of everything
        self.addChild(minimapBackground!)
        
        // Create an outer radar to represent the entire scene borders
        outerMinimapBackground = SKShapeNode(rectOf: minimapSize)
        outerMinimapBackground?.position = CGPoint(x: camera.frame.width - 495, y: 200) // Same position as the radar
        outerMinimapBackground?.fillColor = .clear
        outerMinimapBackground?.strokeColor = .white // Use a different color for the scene borders
        outerMinimapBackground?.lineWidth = 1
        outerMinimapBackground?.zPosition = -2 // Behind the camera radar
        self.addChild(outerMinimapBackground!)

        // Call update to populate radar with dots initially
        updateMinimap()
    }
    
    // Function to update radar with positions of relevant objects
    func updateMinimap() {
        let newMinimapSize: CGSize
        let extraHeight: CGFloat
        
        switch gameScene.universe {
        case .big, .dark:
            newMinimapSize = CGSize(width: minimapSize.width * 2, height: minimapSize.height * 2)
            extraHeight = 150
        case .horizontal:
            newMinimapSize = CGSize(width: minimapSize.width * 2, height: minimapSize.height)
            extraHeight = 0
        case .vertical:
            newMinimapSize = CGSize(width: minimapSize.width, height: minimapSize.height * 2)
            extraHeight = 150
        default:
            newMinimapSize = CGSize(width: minimapSize.width, height: minimapSize.height)
            extraHeight = 0
        }
        
        // Update the path of the outer radar background to match the new size
        outerMinimapBackground?.path = CGPath(rect: CGRect(origin: CGPoint.zero, size: newMinimapSize), transform: nil)
        outerMinimapBackground?.position = CGPoint(x: camera.frame.width - 620, y: 200 - extraHeight)
        
        minimapBackground?.children.filter { $0 != minimapBackground }.forEach { $0.removeFromParent() }
        
        // Get the camera's position
        let cameraPosition = camera.position
        
        // Loop through the background stars and add them to the radar relative to the camera
        gameScene.stars.forEach { debris in
            if let star = debris as? Star {
                let radarDot = SKShapeNode(circleOfRadius: 1)
                radarDot.fillColor = .white
                radarDot.strokeColor = .clear
                radarDot.zPosition = 0
                
                // Scale down the position relative to the camera to fit in the radar
                let scaledX = ((star.position.x - cameraPosition.x) / gameScene.size.width) * minimapSize.width
                let scaledY = ((star.position.y - cameraPosition.y) / gameScene.size.height) * minimapSize.height
                radarDot.position = CGPoint(x: scaledX, y: scaledY)
                
                minimapBackground?.addChild(radarDot)
            }
        }
        
        // Loop through asteroids and other game objects
        gameScene.asteroidList.forEach { asteroid in
            let radarDot = SKShapeNode(circleOfRadius: 2)
            radarDot.fillColor = .clear
            radarDot.strokeColor = .white
            radarDot.zPosition = 0
            
            if let asteroid = asteroid as? Asteroid {
                let scaledX = ((asteroid.position.x - cameraPosition.x) / gameScene.size.width) * minimapSize.width
                let scaledY = ((asteroid.position.y - cameraPosition.y) / gameScene.size.height) * minimapSize.height
                radarDot.position = CGPoint(x: scaledX, y: scaledY)
                
                minimapBackground?.addChild(radarDot)
            }
        }
        
        // Handle bullets, power-ups, and spaceship similarly, always using the camera position as the reference
        gameScene.bulletList.forEach { bullet in
            let radarDot = SKShapeNode(circleOfRadius: 2)
            radarDot.fillColor = .orange
            radarDot.strokeColor = .clear
            radarDot.zPosition = 0
            
            if let playerBullet = bullet as? Bullet {
                let scaledX = ((playerBullet.position.x - cameraPosition.x) / gameScene.size.width) * minimapSize.width
                let scaledY = ((playerBullet.position.y - cameraPosition.y) / gameScene.size.height) * minimapSize.height
                radarDot.position = CGPoint(x: scaledX, y: scaledY)
                
                minimapBackground?.addChild(radarDot)
            }
        }
        
        gameScene.floaterList.forEach { floater in
            let radarDot = SKShapeNode(circleOfRadius: 2)
            radarDot.fillColor = floater is NukeFloater ? .yellow : .cyan
            radarDot.strokeColor = .clear
            radarDot.zPosition = 0
            
            if let floater = floater as? Floater {
                let scaledX = ((floater.position.x - cameraPosition.x) / gameScene.size.width) * minimapSize.width
                let scaledY = ((floater.position.y - cameraPosition.y) / gameScene.size.height) * minimapSize.height
                radarDot.position = CGPoint(x: scaledX, y: scaledY)
                minimapBackground?.addChild(radarDot)
            }
        }
        
        if gameScene.universe == .freeFly {
            let spaceshipDot = SKShapeNode(circleOfRadius: 3)
            spaceshipDot.fillColor = gameScene.falcon.shield > 0 ? .cyan : .orange
            spaceshipDot.strokeColor = .clear
            spaceshipDot.zPosition = 0
        
            let scaledX = ((gameScene.falcon.position.x - cameraPosition.x) / gameScene.size.width) * minimapSize.width
            let scaledY = ((gameScene.falcon.position.y - cameraPosition.y) / gameScene.size.height) * minimapSize.height
            spaceshipDot.position = CGPoint(x: scaledX, y: scaledY)
            
            minimapBackground?.addChild(spaceshipDot)
        }
        else {
            let spaceshipDot = SKShapeNode(circleOfRadius: 3)
            spaceshipDot.fillColor = gameScene.falcon.shield > 0 ? .cyan : .orange
            spaceshipDot.strokeColor = .clear
            spaceshipDot.zPosition = 0
            spaceshipDot.position = CGPoint(x: 0, y: 0) // Center of the camera radar
            minimapBackground?.addChild(spaceshipDot)
        }
    }

    
    // Function to toggle radar visibility
    func toggleRadarVisibility() {
        if gameScene.universe != .dark {
            isRadarVisible.toggle()
            self.isHidden = !isRadarVisible
        }
    }
}
