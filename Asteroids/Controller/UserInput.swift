import Cocoa

enum KeyCode: Int {
    case pause = 35      // p key
    case quit = 12       // q key
    case left = 123      // left arrow
    case right = 124     // right arrow
    case up = 126        // up arrow
    case start = 1       // s key
    case fire = 49       // space bar
    case mute = 46       // m key
    case nuke = 3        // f key
    case radar = 0       // a key
}


@objc
protocol UserInputDelegate: NSObjectProtocol {
    @objc optional func startGame()
    @objc optional func shoot()
    @objc optional func gameOver()
    @objc optional func fireNuke()
    @objc optional func toggleRadar()
    @objc optional func togglePause()
}

class UserInput {
    weak var delegate: UserInputDelegate?
    
    // Movement flags
    var isThrusting = false  // Thrust forward
    var isRotatingLeft = false // Rotate left
    var isRotatingRight = false // Rotate right

    // Method to handle key down events
    func handleKeyDown(event: NSEvent) {
        switch event.keyCode {
        case 126: // Up Arrow (thrust forward)
            isThrusting = true
        case 123: // Left Arrow (rotate left)
            isRotatingLeft = true
        case 124: // Right Arrow (rotate right)
            isRotatingRight = true
        case 46:  // 'M' key (toggle music)
            MusicPlayer.shared.toggleMusic(filename: "dr_loop")
        case 49:  // Spacebar
            delegate?.shoot?()
        case 1:   // 'S' key
            delegate?.startGame?()
        case 12:  // 'Q' key
            delegate?.gameOver?()
        case 3:   // 'F' key
            delegate?.fireNuke?()
        case 0:   // 'A' key
            delegate?.toggleRadar?()
        case 35:  // 'P' key
            delegate?.togglePause?()
        default:
            break
        }
    }
    
    // Method to handle key up events
    func handleKeyUp(event: NSEvent) {
        switch event.keyCode {
        case 126: // Up Arrow (stop thrusting)
            isThrusting = false
        case 123: // Left Arrow (stop rotating left)
            isRotatingLeft = false
        case 124: // Right Arrow (stop rotating right)
            isRotatingRight = false
        default:
            break
        }
    }
}
