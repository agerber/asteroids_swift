//
//  Spaceship.swift
//  SpaceInvaders
//
//  Created by Furkan Baytemur on 5.10.2024.
//

import SpriteKit

class Spaceship: SKSpriteNode {
    
    // Rotation speed in radians per update
    var rotationSpeed: CGFloat = .pi / 60 // 3 degrees per frame
    
    // Initialize the spaceship with an image
    init() {
        let texture = SKTexture(imageNamed: "falcon") // Ensure "player" image is in Assets
        super.init(texture: texture, color: .clear, size: texture.size())
        self.name = "player"
        
        // Setup physics body for collision detection
        self.physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = 1
        self.physicsBody?.contactTestBitMask = 2
        self.physicsBody?.collisionBitMask = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Rotate the spaceship clockwise
    func rotateClockwise() {
        let rotateAction = SKAction.rotate(byAngle: -rotationSpeed, duration: 0.0)
        self.run(rotateAction)
    }
    
    // Rotate the spaceship counter-clockwise
    func rotateCounterClockwise() {
        let rotateAction = SKAction.rotate(byAngle: rotationSpeed, duration: 0.0)
        self.run(rotateAction)
    }
}
