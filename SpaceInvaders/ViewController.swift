//
//  ViewController.swift
//  SpaceInvaders
//
//  Created by Furkan Baytemur on 5.10.2024.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            // Ensure the view is an SKView
            guard let skView = self.view as? SKView else {
                fatalError("View is not an SKView")
            }
            
            // Create the GameScene with the view's bounds
            let scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .resizeFill // Ensures the scene resizes with the view
            
            // Present the scene
            skView.presentScene(scene)
            
            skView.ignoresSiblingOrder = true
            
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
}

