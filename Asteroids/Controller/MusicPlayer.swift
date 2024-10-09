import SpriteKit
import AVFoundation

class MusicPlayer {
    
    static let shared = MusicPlayer() // Singleton instance
    
    private var audioPlayer: AVAudioPlayer?
    private var isMusicPlaying = false
    
    private var thrustSoundPlayer: AVAudioPlayer?
    
    private init() {}
    
    // Function to play the music
    func playMusic(filename: String) {
        if isMusicPlaying {
            return // Music is already playing, no need to play again
        }
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: "wav") else {
            print("Could not find music file \(filename)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isMusicPlaying = true
        } catch {
            print("Error playing music: \(error)")
        }
    }
    
    // Function to stop the music
    func stopMusic() {
        audioPlayer?.stop()
        isMusicPlaying = false
    }
    
    // Toggle music on/off
    func toggleMusic(filename: String) {
        if isMusicPlaying {
            stopMusic()
        } else {
            playMusic(filename: filename)
        }
    }
    
    func startThrustSound() {
        if let thrustSoundUrl = Bundle.main.url(forResource: "whitenoise_loop", withExtension: "wav") {
            do {
                thrustSoundPlayer = try AVAudioPlayer(contentsOf: thrustSoundUrl)
                thrustSoundPlayer?.numberOfLoops = -1 // Loop indefinitely
                thrustSoundPlayer?.play()
            } catch {
                print("Error loading thrust sound: \(error)")
            }
        }
    }
    
    // Stop the thrust sound
    func stopThrustSound() {
        thrustSoundPlayer?.stop()
    }
    
    func playSoundEffect(filename: String, gameScene: GameScene) {
        let hitSound = SKAction.playSoundFileNamed(filename, waitForCompletion: false)
        gameScene.run(hitSound)
    }
}
