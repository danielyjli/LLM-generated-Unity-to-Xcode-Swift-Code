import SwiftUI
import AVFoundation
import SceneKit

public struct GameOverManager: System {
    public var resultText: Text
    public var scoreText: Text
    public var timeText: Text
    public var mirrortext: Text
    public var soundClip1: AudioClip
    public var soundClip2: AudioClip
    private var audioSource: AudioSource
    public var outputMixer: AudioMixerGroup
    
    public init() {
        // Initialize audio source
        audioSource = SceneKit.ViewController().gameObject.AddComponent("AudioSource") as? AudioSource
        audioSource.outputAudioMixerGroup = outputMixer
        
        // Initialize UI components
        resultText = Text()
        scoreText = Text()
        timeText = Text()
        mirrortext = Text()
    }
    
    private func DestroyGeneratedItems() {
        // 查找并销毁所有生成的道具实例
        let tags = tagsToDestroy
        for tag in tags {
            let sceneObjects = SceneKit.ViewController().findGameObjects(with: tag)
            sceneObjects.forEach { obj in
                obj.destroy()
            }
        }
    }
    
    public func update(_ delta: Double) {
        // Get game state from PlayerPrefs
        let gameWon = PlayerPrefs.GetInt("GameWon") == 1
        let score = PlayerPrefs.GetInt("Score")
        let time = PlayerPrefs.GetFloat("Time")
        
        // Update UI text
        resultText.text = gameWon ? "You have successfully escaped" : "You are still trapped in it"
        scoreText.text = "Score\n\(score)"
        let roundedTime = Math.round(time)
        timeText.text = "Time\n\(roundedTime)"
        
        // Play appropriate sound based on game state
        if !gameWon {
            audioSource.playOneShot(soundClip2)
        } else {
            audioSource.playOneShot(soundClip1)
        }
        
        // Reset UI for second screen
        if !gameWon {
            resultText1.text = resultText.text
            scoreText1.text = scoreText.text
            timeText1.text = timeText.text
        } else {
            resultText1.text = ""
            scoreText1.text = ""
            timeText1.text = ""
            mirrortext.text = ""
        }
    }
    
    public func onCollisionEnter(_ other: Collision) {
        // Handle collision events
        print("Game Over collision detected")
        DestroyGeneratedItems()
    }
    
    public func onTriggerEnter(_ other: Trigger) {
        // Handle trigger events
        print("Game Over trigger entered")
    }
}