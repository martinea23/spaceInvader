//
//  gameOverScene.swift
//  FinalProject
//
//  Created by Axl Martinez on 12/3/21.
//

import Foundation
import SpriteKit

let restartLabel = SKLabelNode(fontNamed: "Short Baby Font")
class gameOverScene: SKScene{
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2 , y: self.size.height/2) // makesure its in middle of phone
        background.zPosition = 0 //Layering
        self.addChild(background)// makes the background
        
        let GameOverLabel = SKLabelNode(fontNamed: "Short Baby Font")
        GameOverLabel.text = "Game Over"
        GameOverLabel.fontSize = 150
        GameOverLabel.fontColor = SKColor.white
        GameOverLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.6) // place it on top left
        GameOverLabel.zPosition = 100 // to keep it on top always
        self.addChild(GameOverLabel) // create it
        
        let ScoreLabel = SKLabelNode(fontNamed: "Short Baby Font")
        ScoreLabel.text = "Score = \(Score)"
        ScoreLabel.fontSize = 150
        ScoreLabel.fontColor = SKColor.white
        ScoreLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        ScoreLabel.zPosition = 100
        self.addChild(ScoreLabel)
        
    
        restartLabel.text = "Restart"
        restartLabel.fontSize = 150
        restartLabel.fontColor = SKColor.white
        restartLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.4)
        restartLabel.zPosition = 100
        self.addChild(restartLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let POT = touch.location(in: self)
            if restartLabel.contains(POT){
                let SceneChange = GameScene(size: self.size)
                SceneChange.scaleMode = self.scaleMode
                let trans = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(SceneChange, transition: trans)
            }
            
        }
    }
    
}
