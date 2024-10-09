import Foundation

struct PhysicsCategory {
    static let none      : UInt32 = 0
    static let spaceship : UInt32 = 0b1       // 1
    static let asteroid  : UInt32 = 0b10      // 2
    static let bullet    : UInt32 = 0b100     // 4
    static let powerUp   : UInt32 = 0b1000    // 8
    static let nuke      : UInt32 = 0b10000   // 16
}
