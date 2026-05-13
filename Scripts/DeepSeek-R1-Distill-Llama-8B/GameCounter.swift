import Foundation
import SwiftUI
import SceneManager
import SpriteKit

struct GameCounter : Identifiable {
    @StateObject private var gameCounter = GameCounterData()
    private var bricks: [GameObject] = []
    private var score = 0
    private var time = 0.0
    private var gameWon = false
    private var gameOver = false
    
    init() {
        bricks = GameObject.FindGameObjectsWithTag("Brick")
        score = 0
        time = 0.0
        gameWon = false
    }
    
    private var timer: Timer {
        get {
            return Timer()
        }
        set {
            timer.start()
        }
    }
    
    private func handleUpdate() {
        if !gameWon && !gameOver {
            time += Time.deltaTime
            scoreText.text = "Score: \(score)"
            timeText.text = "Time: \(Math.round(time))"
        }
    }
    
    func addScore(_ randomScore: Int) {
        score += randomScore
    }
    
    func brickDestroyed(_ brick: GameObject) {
        bricks.removeOne()
        Destroy(brick)
        
        if bricks.isEmpty {
            gameWon = true
            gameOver = true
            gameOver()
        }
    }
    
    func ballEnteredDeathZone() {
        if !gameOver {
            gameOver = true
            gameOver()
        }
    }
    
    private func gameOver() {
        // 保存胜利/失败、积分和时间信息
        let userDefaults = UserDefaults.standard
        userDefaults.setInteger(score, forKey: "Score")
        userDefaults.setFloat(time, forKey: "Time")
        userDefaults.setInteger(gameWon ? 1 : 0, forKey: "GameWon")
        
        // 进行场景转换
        SceneManager.LoadScene("GameOverScene")
    }
}

struct GameCounterData : Equatable {
    var score: Int = 0
    var time: Float = 0.0
    var gameWon: Bool = false
    var gameOver: Bool = false
}