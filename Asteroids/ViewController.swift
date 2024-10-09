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
        let scene = GameOverScene(size: CGSize(width: 1280, height: 720))
        
        // Present the scene
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        // Prevent resizing of the window
        if let window = self.view.window {
            window.styleMask.remove(.resizable)
            
            // Set fixed window size
            window.setContentSize(NSSize(width: 1280, height: 720))
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // Ensure the window cannot be resized and is fixed
        if let window = self.view.window {
            window.styleMask.remove(.resizable)
            window.setContentSize(NSSize(width: 1280, height: 720))
        }
    }
}

