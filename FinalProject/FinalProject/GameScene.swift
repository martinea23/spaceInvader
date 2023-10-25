//
//  GameScene.swift
//  FinalProject
//
//  Created by Axl Martinez on 12/3/21.
//

import SpriteKit
import GameplayKit

var Score = 0

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    // to be accessed everywhere
 
    let player = SKSpriteNode(imageNamed: "playerShip")
    let gameArea: CGRect
    
 
    let ScoreLabel = SKLabelNode(fontNamed: "Short Baby Font")
    
    var Lives = 3
    let LivesLabel = SKLabelNode(fontNamed: "Short Baby Font")
    
    var time = 1.0
    var level = 1
    let levelLabel = SKLabelNode(fontNamed: "Short Baby Font")
    
    enum gameState { // USED TO PREVENT SHOOTING OR SPAWNING AFTER GAME IS OVER
        case preGame
        case duringGame
        case afterGame
    }
    
    var currentGameState = gameState.duringGame
    
    struct PhysicsCat{
        static let None: UInt32 = 0
        static let player: UInt32 = 0b1 //1
        static let bullet: UInt32 = 0b10//2
        static let Enemy: UInt32 = 0b100 //4
    }
    
    // random number generators
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
            
        return CGFloat(arc4random_uniform(UInt32(max - min)) + UInt32(min))
           
    }
    
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 6.0/2.75
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth ) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func gameOver(){
        
        currentGameState = gameState.afterGame // end game
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Bullet"){
            bullet, stop in
            bullet.removeAllActions()
            
        }
        self.enumerateChildNodes(withName: "enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        
        let changeScene = SKAction.run(changeScene)
        let wait = SKAction.wait(forDuration: 1)
        let changeSeq = SKAction.sequence([wait,changeScene])
        self.run(changeSeq)
        
    }
    
    func changeScene(){
        // to make sure our scene is the same size
        let sceneToMove2 = gameOverScene(size: self.size)
        sceneToMove2.scaleMode = self.scaleMode
        let trans = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMove2, transition: trans)
    }
    
    override func didMove(to view: SKView) { // Happens Staright Away
        Score = 0
        self.physicsWorld.contactDelegate = self // lets us see collisions
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2 , y: self.size.height/2) // makesure its in middle of phone
        background.zPosition = 0 //Layering
        self.addChild(background)// makes the background
        
       
        player.setScale(1) // size of player
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2 )
        // where the player starts
        player.zPosition = 2 // layering
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false // so gravity does not affect
        player.physicsBody!.isDynamic = false
        
        player.physicsBody!.categoryBitMask = PhysicsCat.player // assign the body
        player.physicsBody!.collisionBitMask = PhysicsCat.None // no collisions allowed
        player.physicsBody!.contactTestBitMask = PhysicsCat.Enemy // only crash with enemy
        self.addChild(player) // create it
        
        ScoreLabel.text = "Score 0"
        ScoreLabel.fontSize = 70
        ScoreLabel.fontColor = SKColor.white
        ScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left // to make it grow right
        ScoreLabel.position = CGPoint(x: self.size.width * 0.25, y: self.size.height*0.9) // place it on top left
        ScoreLabel.zPosition = 100 // to keep it on top always
        self.addChild(ScoreLabel) // create it
        
        LivesLabel.text = "Lives 3"
        LivesLabel.fontSize = 70
        LivesLabel.fontColor = SKColor.white
        LivesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        LivesLabel.position = CGPoint(x: self.size.width * 0.6, y: self.size.height * 0.9)
        LivesLabel.zPosition = 100
        self.addChild(LivesLabel)
        
        levelLabel.text = "Level 1"
        levelLabel.fontSize = 70
        levelLabel.fontColor = SKColor.white
        levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        levelLabel.position = CGPoint(x: self.size.width * 0.425 , y: self.size.height * 0.85)
        levelLabel.zPosition = 100
        self.addChild(levelLabel)
        
        startNewLevel()
    }
    func loseLife(){
        Lives -= 1
        LivesLabel.text = "Lives: \(Lives)"
        
        if Lives == 0{
            gameOver()
        }
        
    }
    func addScore(){
        Score += 1
        ScoreLabel.text = "Score: \(Score)"
    }
    func levelUp(){
        if time > 0.5{
            time = time - 0.1
            level += 1
        }
        levelLabel.text = "Level : \(level)"
        startNewLevel()
    }
    
    func startNewLevel() {
        let spawn = SKAction.run(spawnEnemy)
        let wait = SKAction.wait(forDuration: time)
        let spawnSequence = SKAction.sequence([spawn,wait])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever)
    }
    
    func fire(){
        let bullet = SKSpriteNode(imageNamed: "bullet")
        setScale(1)
        bullet.name = "Bullet"
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody?.isDynamic = false
        
        bullet.physicsBody!.categoryBitMask = PhysicsCat.bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCat.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCat.Enemy
   
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
    
        let bulletSequence = SKAction.sequence([moveBullet,deleteBullet])
        bullet.run(bulletSequence)
    }

    func spawnEnemy(){
        let randXBeg = random(min: gameArea.minX, max: gameArea.maxX)
        let randXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        let start = CGPoint(x: randXBeg, y: self.size.height * 1.2)
        let End = CGPoint(x: randXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.setScale(1)
        enemy.zPosition = 2
        enemy.position = start
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
      
        
        enemy.physicsBody!.categoryBitMask = PhysicsCat.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCat.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCat.player | PhysicsCat.bullet
        
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: End, duration: 5)
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy,deleteEnemy])
        if currentGameState == gameState.duringGame{
            enemy.run(enemySequence)
        }
    
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState == gameState.duringGame {
            fire()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let POT = touch.location(in: self)
            let prevPOT = touch.previousLocation(in: self)
            let Diff = POT.x - prevPOT.x
            
            if currentGameState == gameState.duringGame {
                player.position.x += Diff
            }
            
            if player.position.x > gameArea.maxX - player.size.width/2{
                player.position.x = gameArea.maxX - player.size.width/2
            }
            
            if player.position.x < gameArea.minX + player.size.width/2{
                player.position.x = gameArea.minX + player.size.width/2
            }
        }
        
    }
    
    func spawnDeath(spawnPosition: CGPoint){
        let death = SKSpriteNode(imageNamed: "death")
        death.position = spawnPosition
        death.zPosition = 3
        death.setScale(0)
        self.addChild(death)
        
        let scale = SKAction.scale(to: 1, duration: 0.2)
        let fade = SKAction.fadeOut(withDuration: 0.2)
        let delete = SKAction.removeFromParent()

        let deathSequence = SKAction.sequence([scale,fade,delete])
        death.run(deathSequence)
    }
    
    func didBegin(_ contact: SKPhysicsContact){
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{ //put them in order
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else{
            body2 = contact.bodyA
            body1 = contact.bodyB
        }
        
        if body1.categoryBitMask == PhysicsCat.player && body2.categoryBitMask==PhysicsCat.Enemy{
            // player hits enemy
            // 1 is player 2 is enemy
            spawnDeath(spawnPosition: body2.node!.position) // at players position
            if (Lives == 0){
                spawnDeath(spawnPosition: body1.node!.position)
            }
            loseLife()
            body2.node?.removeFromParent()
        }
        if body1.categoryBitMask == PhysicsCat.bullet && body2.categoryBitMask==PhysicsCat.Enemy{
            //bullet hits enemy
            // 1 is bullet , 2 is enemy
            if body2.node != nil{
                if body2.node!.position.y > self.size.height{
                    return // just to make sure the enemy is on screen
                }
                else{
                    addScore()
                    spawnDeath(spawnPosition: body2.node!.position)// at players position
                    body2.node?.removeFromParent()
                    body1.node?.removeFromParent()
                }
            }
            
            if (Score == 10){
                levelUp()
            }
            if (Score == 20){
                levelUp()
            }
            if (Score == 30){
                levelUp()
            }
            if (Score == 40){
                levelUp()
            }
            if (Score == 50){
                levelUp()
            }
            if (Score == 60){
                levelUp()
            }
        }
        
    }
   
}
