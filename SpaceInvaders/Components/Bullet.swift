//
//  Bullet.swift
//  SpaceInvaders
//
//  Created by Furkan Baytemur on 5.10.2024.
//

import SpriteKit

class Bullet: SKShapeNode {
    // Constants for bullet behavior
    let firePower: CGFloat = 500 // Increased for better visibility
    let kickbackDivisor: CGFloat = 24
    let bulletLifetime: TimeInterval = 1.5

    // Initialize the bullet with reference to Spaceship
    init(spaceship: Spaceship) {
        super.init()

        // Define the shape of the bullet (a cursor-like triangle)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 6))    // Tip of the cursor
        path.addLine(to: CGPoint(x: -3, y: -3)) // Bottom left corner
        path.addLine(to: CGPoint(x: 3, y: -3))  // Bottom right corner
        path.closeSubpath()

        // Set the path for the SKShapeNode to render the triangle
        self.path = path
        self.fillColor = .orange
        self.strokeColor = .white
        self.lineWidth = 1

        // Set the bullet's position based on the Spaceship
        self.position = spaceship.position
        self.zRotation = spaceship.zRotation - CGFloat.pi / 2

        // Set up physics body for collision detection
        self.physicsBody = SKPhysicsBody(polygonFrom: path)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.bullet
        self.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
        self.physicsBody?.affectedByGravity = false // Disable gravity for bullets
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.mass = 0

        // Calculate bullet velocity based on the Spaceship's orientation
        let direction = CGVector(dx: cos(spaceship.zRotation), dy: sin(spaceship.zRotation))
        let bulletVelocity = CGVector(dx: direction.dx * firePower, dy: direction.dy * firePower)

        // Set the bullet's velocity
        self.physicsBody?.velocity = bulletVelocity

        // Apply kickback to the Spaceship
        let kickback = CGVector(dx: -bulletVelocity.dx / kickbackDivisor, dy: -bulletVelocity.dy / kickbackDivisor)
        spaceship.physicsBody?.applyImpulse(kickback)

        // Set the bullet's lifespan (expiry)
        let expireAction = SKAction.sequence([
            SKAction.wait(forDuration: bulletLifetime),
            SKAction.removeFromParent()
        ])
        self.run(expireAction)

        // Play sound effect when the bullet is added (optional)
        // Uncomment the following line if you have a sound file named "thump.wav" in your project
        // self.run(SKAction.playSoundFileNamed("thump.wav", waitForCompletion: false))
    }

    // Required by Swift for NSCoder compliance, can be omitted if not using NSCoder
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
