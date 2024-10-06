//
//  PhysicsCategory.swift
//  SpaceInvaders
//
//  Created by Furkan Baytemur on 5.10.2024.
//

import Foundation

struct PhysicsCategory {
    static let none      : UInt32 = 0
    static let spaceship : UInt32 = 0b1       // 1
    static let enemy     : UInt32 = 0b10      // 2
    static let bullet    : UInt32 = 0b100     // 4
}
