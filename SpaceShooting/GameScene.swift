//
//  GameScene.swift
//  SpaceShooting
//
//  Created by 임재현 on 2023/09/08.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    var meteorTimer = Timer()
    var meteorInterval: TimeInterval = 2.0
    var enemyTimer = Timer()
    var enemyInterval: TimeInterval = 1.2
    var itemTimer = Timer()
    var itemInterval: TimeInterval = 3.0
    
    var player:Player!
    var playerFireTimer = Timer()
    
    var shield = SKSpriteNode()
    var isShieldOn = false
    var shieldCount: Int = 0
    
    
    let cameraNode = SKCameraNode()
    let hud = Hud()
    var boss:Boss?
    var isBossOnScreen = false
    var bossNumber = 2
    var bossFireTimer1 = Timer()
    var bossFireTimer2 = Timer()
    
    var continueScreen = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        //BGM
        let bgmPlayer = SKAudioNode(fileNamed: BGM.main)
        bgmPlayer.autoplayLooped = true
        self.addChild(bgmPlayer)
        
        //카메라 추가
        self.camera = cameraNode
        cameraNode.position.x = self.size.width / 2
        cameraNode.position.y = self.size.height / 2
        self.addChild(cameraNode)
        
        
        
        //배경용 별무리 붙이기
        guard let starfield = SKEmitterNode(fileNamed: Particle.starField) else {return}
        starfield.position = CGPoint(x: size.width / 2 , y: size.height)
        starfield.zPosition = Layer.starField
        starfield.advanceSimulationTime(30)
        self.addChild(starfield)
        
        hud.createHud(screenSize: self.size)
        self.addChild(hud)
        
        
        
        //  addMeteor()
        meteorTimer = setTimer(interval: meteorInterval, function: self.addMeteor)
        enemyTimer = setTimer(interval: enemyInterval, function: self.addEnemy)
        itemTimer = setTimer(interval: itemInterval, function: self.addItem)
        
        // 플레이어 배치
        player = Player(screenSize: self.size)
        player.position = CGPoint(x: size.width / 2 , y: player.size.height * 2 )
        self.addChild(player)
        
        playerFireTimer = setTimer(interval: 0.4, function: self.playerFire)
        
        //보스 배치후 출현시킴
        //
        //        boss = Boss(screenSize: self.size, level: 1)
        //        addChild(boss!)
        //        boss!.appear()
    }
    
    func playerFire() {
        let missile = self.player.createMissile()
        self.addChild(missile)
        self.player.fireMissile(missile: missile)
        self.run(SoundFx.playerFire)
    }
    
    // 보스 직선샷
    func bossFire() {
        guard let boss = boss else { return }
        let missile = boss.createMissile()
        self.addChild(missile)
        let action = SKAction.sequence([SKAction.moveTo(y: -missile.size.width, duration: 3.0), SKAction.removeFromParent()])
        missile.run(action)
        
        self.run(SoundFx.bossFire)
    }
    
    // 보스 원형샷
    func bossCircleFire(bPoint: CGPoint) {
        guard let boss = boss else { return }
        
        let separate: Double = 30.0
        let missileSpeed: TimeInterval = 8.0
        
        for i in 0 ..< Int(separate) {
            let r: CGFloat = self.size.height
            let x: CGFloat = r * CGFloat(cos((Double(i) * 2 * Double.pi / separate)))
            let y: CGFloat = r * CGFloat(sin((Double(i) * 2 * Double.pi / separate)))
            
            let action = SKAction.sequence([SKAction.move(to: CGPoint(x: bPoint.x + x, y: bPoint.y + y), duration: missileSpeed), SKAction.removeFromParent()])
            let missile = boss.createMissile()
            self.addChild(missile)
            missile.run(action)
        }
        
        self.run(SoundFx.bossFire)
    }
    
    
    func addMeteor() {
        let randomMeteor = arc4random_uniform(UInt32(3)) + 1
        let randomXPos = CGFloat(arc4random_uniform(UInt32(self.size.width)))
        let randomSpeed = TimeInterval(arc4random_uniform(UInt32(5))+5 )
        
        let texture = Atlas.gameobject.textureNamed("meteor\(randomMeteor)")
        let meteor = SKSpriteNode(texture: texture)
        meteor.name = "meteor"
        meteor.position = CGPoint(x: randomXPos, y: self.size.height + meteor.size.height)
        meteor.zPosition = Layer.meteor
        
        meteor.physicsBody = SKPhysicsBody(texture: texture, size: meteor.size)
        meteor.physicsBody?.categoryBitMask = PhysicsCategory.meteor
        meteor.physicsBody?.contactTestBitMask = 0
        meteor.physicsBody?.collisionBitMask = 0
        self.addChild(meteor)
        
        let moveAct = SKAction.moveTo(y: -meteor.size.height, duration: randomSpeed)
        let rotateAct = SKAction.rotate(toAngle: CGFloat(Double.pi), duration: randomSpeed)
        let moveAndRotateAct = SKAction.group([moveAct,rotateAct])
        let removeAct = SKAction.removeFromParent()
        
        meteor.run(SKAction.sequence([moveAndRotateAct,removeAct]))
    }
    
    func addEnemy() {
        let randomEnemy = arc4random_uniform(UInt32(3)) + 1
        let randomXPos = self.player.size.width / 2 + CGFloat(arc4random_uniform(UInt32(self.size.width - self.player.size.width / 2 )))
        let randomSpeed = TimeInterval(arc4random_uniform(UInt32(3)) + 3 )
        let texture = Atlas.gameobject.textureNamed("enemy\(randomEnemy)")
        let enemy = SKSpriteNode(texture: texture)
        enemy.name = "enemy"
        enemy.position = CGPoint(x: randomXPos, y: self.size.height + enemy.size.height)
        enemy.zPosition = Layer.enemy
        
        //물리바디 부여
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.height / 2)
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        enemy.physicsBody?.contactTestBitMask = 0
        enemy.physicsBody?.collisionBitMask = 0
        self.addChild(enemy)
        
        guard let thruster = SKEmitterNode(fileNamed: Particle.enemyThruster) else {return}
        thruster.zPosition = Layer.sub
        let thrusterEffectNode = SKEffectNode()
        thrusterEffectNode.addChild(thruster)
        enemy.addChild(thrusterEffectNode)
        
        let moveAct = SKAction.moveTo(y: -enemy.size.height, duration: randomSpeed)
        let removeAct = SKAction.removeFromParent()
        
        enemy.run(SKAction.sequence([moveAct,removeAct]))
    }
    
    func addItem() {
        let itemList = ["itemlightning", "itemshield", "itemstar"]
        let randomItem = Int(arc4random_uniform(UInt32(itemList.count)))
        let randomXPos = CGFloat(arc4random_uniform(UInt32(self.size.width)))
        let randomSpeed = TimeInterval(arc4random_uniform(UInt32(10)) + 5)
        
        let texture = Atlas.gameobject.textureNamed(itemList[randomItem])
        let item = SKSpriteNode(texture: texture)
        item.position = CGPoint(x: randomXPos, y: self.size.height + item.size.height)
        item.zPosition = Layer.item
        
        // 물리바디 부여
        item.physicsBody = SKPhysicsBody(circleOfRadius: item.size.height / 2)
        item.physicsBody?.categoryBitMask = PhysicsCategory.item
        item.physicsBody?.contactTestBitMask = 0
        item.physicsBody?.collisionBitMask = 0
        self.addChild(item)
        
        // 아이템을 name 속성으로 구분
        switch itemList[randomItem] {
        case "itemlightning":
            item.name = "lightning"
        case "itemstar":
            item.name = "star"
        case "itemshield":
            item.name = "shield"
        default:
            break
        }
        
        let moveAction = SKAction.moveTo(y: -item.size.height, duration: randomSpeed)
        let removeAction = SKAction.removeFromParent()
        item.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    
    
    
    
    func setTimer(interval: TimeInterval, function:@escaping() -> Void) -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            function()
            
        }
        timer.tolerance = interval * 0.2
        
        return timer
    }
    
    func setTimer(interval: TimeInterval, function:@escaping (CGPoint) -> Void) -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            guard let boss = self.boss else { return }
            function(boss.position)
        }
        timer.tolerance = interval * 0.2
        
        return timer
    }
    
    func explosion(targetNode:SKSpriteNode,isSmall:Bool) {
        let particle: String!
        if isSmall {
            particle = Particle.hit
            
        } else {
            particle = Particle.explosion
        }
        
        guard let explosion = SKEmitterNode(fileNamed: particle) else {return}
        explosion.position = targetNode.position
        explosion.zPosition = targetNode.zPosition
        self.addChild(explosion)
        self.run(SoundFx.explosion)
        self.run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
        
    }
    
    func playerDamageEffect() {
        //화면 빨간색으로 점멸
        let flashNode = SKSpriteNode(color: SKColor.red,size: self.size)
        flashNode.position = CGPoint(x: self.size.width/2, y: self.size.height / 2)
        flashNode.zPosition = Layer.hud
        self.addChild(flashNode)
        flashNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.01),SKAction.removeFromParent()]))
        
        //화면 흔들기
        let moveLeft = SKAction.moveTo(x: self.size.width / 2 - 5, duration: 0.1)
        let moveRight = SKAction.moveTo(x: self.size.width / 2 + 5, duration: 0.1)
        let moveCenter = SKAction.moveTo(x: self.size.width / 2 , duration: 0.1)
        let shakeAction = SKAction.sequence([moveLeft,moveRight,moveLeft,moveRight,moveCenter])
        shakeAction.timingMode = .easeInEaseOut
        self.cameraNode.run(shakeAction)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var location: CGPoint!
        if let touch = touches.first {
            location = touch.location(in: self)
            
        }
        self.player.run(SKAction.moveTo(x: location.x, duration: 0.2))
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //   playerFire()
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            if let nodeName = nodesArray.first?.name {
                switch nodeName {
                case "restartBtn":
                    restart()
                default:
                    break
                }
            }
        }
    }
    
    func gameover() {
        // 모든 피탄효과 삭제
        self.enumerateChildNodes(withName: "flashNode") { node, _ in
            node.removeFromParent()
        }
        
        // 모든 타이머 정지
        itemTimer.invalidate()
        meteorTimer.invalidate()
        enemyTimer.invalidate()
        playerFireTimer.invalidate()
        
        if isBossOnScreen == true {
            bossFireTimer1.invalidate()
            bossFireTimer2.invalidate()
        }
        
        saveHighscore()
        
        continueScreen = createContinueScreen()
        self.addChild(continueScreen)
        self.isPaused = true
    }
    func createContinueScreen() -> SKSpriteNode {
        
        continueScreen = SKSpriteNode(color: SKColor.darkGray, size: size)
        continueScreen.position = CGPoint(x: size.width / 2, y: size.height / 2)
        continueScreen.zPosition = Layer.gameover
        continueScreen.alpha = 0.9
        
        let continueLabel = SKLabelNode(text: "Continue?")
        continueLabel.fontName = "Minercraftory"
        continueLabel.fontSize = 40
        continueLabel.position = CGPoint(x: 0, y: size.height * 0.35)
        continueLabel.zPosition = Layer.upper
        continueScreen.addChild(continueLabel)
        
        let scoreLabel = SKLabelNode(text: String(format: "Score: %d", self.hud.score))
        scoreLabel.fontName = "Minercraftory"
        scoreLabel.fontSize = 25
        scoreLabel.position = CGPoint(x: 0, y: size.height * 0.20)
        scoreLabel.zPosition = Layer.upper
        continueScreen.addChild(scoreLabel)
        
        let highScoreLabel = SKLabelNode(text: String(format: "High Score: %d", UserDefaults.standard.integer(forKey: "highScore")))
        highScoreLabel.fontName = "Minercraftory"
        highScoreLabel.fontSize = 25
        highScoreLabel.position = CGPoint(x: 0, y: size.height * 0.13)
        highScoreLabel.zPosition = Layer.upper
        continueScreen.addChild(highScoreLabel)
        
                let restartTexture = Atlas.gameobject.textureNamed("restartBtn")
                let restartBtn = SKSpriteNode(texture: restartTexture)
                restartBtn.name = "restartBtn"
        
      
        
        restartBtn.position = CGPoint(x: 0, y: size.height * -0.05)
        restartBtn.zPosition = Layer.upper
        continueScreen.addChild(restartBtn)
        
        return continueScreen
    }
    func restart() {
        continueScreen.removeFromParent()
        self.isPaused = false
        
        self.hud.addLives()
        
        meteorTimer = setTimer(interval: meteorInterval, function: self.addMeteor)
        enemyTimer = setTimer(interval: enemyInterval, function: self.addEnemy)
        itemTimer = setTimer(interval: itemInterval, function: self.addItem)
        playerFireTimer = setTimer(interval: 0.4, function: self.playerFire)
        
        if boss?.bossState == .secondStep {
            bossFireTimer1 = setTimer(interval: 2.0, function: bossFire)
        } else if boss?.bossState == .thirdStep {
            bossFireTimer1 = setTimer(interval: 2.0, function: bossFire)
            bossFireTimer2 = setTimer(interval: 3.0, function: bossCircleFire(bPoint:))
        }
    }
    
    func saveHighscore() {
        let userDefaults = UserDefaults.standard
        let highScore = userDefaults.integer(forKey: "highScore")
        
        if self.hud.score > highScore {
            userDefaults.set(self.hud.score, forKey: "highScore")
        }
        userDefaults.synchronize()
    }
    
    func stageClear() {
        meteorTimer.invalidate()
        enemyTimer.invalidate()
        itemTimer.invalidate()
        
        meteorInterval -= 0.5
        enemyInterval -= 0.5
        itemInterval += 0.5
        
        meteorTimer = setTimer(interval: meteorInterval, function: self.addMeteor)
        enemyTimer = setTimer(interval: enemyInterval, function: self.addEnemy)
        itemTimer = setTimer(interval: itemInterval, function: self.addItem)
    }
    
    func gameClear() {
        saveHighscore()
        
        let transition = SKTransition.crossFade(withDuration: 5.0)
        let creditScene = ClearScene(size: size)
        creditScene.scaleMode = .aspectFit
        self.view?.presentScene(creditScene, transition: transition)
    }
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.meteor {
            print("player and meteor!")
            
            guard let targetNode = secondBody.node as? SKSpriteNode else {return}
            explosion(targetNode: targetNode, isSmall: false)
            targetNode.removeFromParent()
            
            playerDamageEffect()
            hud.subtractLive()
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.enemy {
            print("player and enemy!")
            
            guard let targetNode = secondBody.node as? SKSpriteNode else {return}
            explosion(targetNode: targetNode, isSmall: true)
            targetNode.removeFromParent()
            
            playerDamageEffect()
            hud.subtractLive()
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.bossMissile {
            guard let targetNode = secondBody.node as? SKSpriteNode else {return}
            explosion(targetNode: targetNode, isSmall: true)
            targetNode.removeFromParent()
            
            playerDamageEffect()
            hud.subtractLive()
        }
        
        // 실드 접촉 판정
        if firstBody.categoryBitMask == PhysicsCategory.shield {
            guard let targetNode = secondBody.node as? SKSpriteNode else { return }
            
            explosion(targetNode: targetNode, isSmall: true)
            targetNode.removeFromParent()
            
            shieldCount -= 1
            if shieldCount <= 0 {
                self.shield.removeFromParent()
                isShieldOn = false
            }
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.item {
            print("player and items!")
            
            
            guard let targetNode = secondBody.node as? SKSpriteNode else { return }
            let name = targetNode.name
            switch name {
            case "lightning":
                
                // 노드를 검색하면서 처리
                enumerateChildNodes(withName: "enemy") { node, _ in
                    if let enemyNode = node as? SKSpriteNode {
                        self.explosion(targetNode: enemyNode, isSmall: true)
                        enemyNode.removeFromParent()
                        
                        self.hud.score += 10
                    }
                }
                
                enumerateChildNodes(withName: "meteor") { node, _ in
                    if let meteorNode = node as? SKSpriteNode {
                        self.explosion(targetNode: meteorNode, isSmall: false)
                        meteorNode.removeFromParent()
                    }
                }
            case "star":
                
                // 플레이어 타이머를 정지
                playerFireTimer.invalidate()
                
                // 스타 효과를 지속할 시간
                var starTime: Int = 50
                
                // 인터벌을 반으로 줄인 타이머를 실행
                playerFireTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                    starTime -= 1
                    
                    self.playerFire()
                    
                    // 스타 효과가 끝나면 다시 타이머 인터벌을 되돌림
                    if starTime <= 0 {
                        self.playerFireTimer.invalidate()
                        self.playerFireTimer = self.setTimer(interval: 0.4, function: self.playerFire)
                    }
                }
                playerFireTimer.tolerance = 0.1
                
            case "shield":
                print("shield")
                
                if !isShieldOn {
                    shield = self.player.createShield()
                    player.addChild(shield)
                    isShieldOn = true
                    shieldCount = 1
                }
                
            default:
                break
            }
            
                self.run(SoundFx.item)
            targetNode.removeFromParent()
            
            
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.missile && secondBody.categoryBitMask == PhysicsCategory.meteor {
            print("missile and meteor!")
            
            guard let targetNode = secondBody.node as? SKSpriteNode else {return}
            explosion(targetNode: targetNode, isSmall: false)
            targetNode.removeFromParent()
            
            firstBody.node?.removeFromParent()
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.missile && secondBody.categoryBitMask == PhysicsCategory.enemy {
            print("missile and enemy!")
            
            self.hud.score += 10
            
            guard let targetNode = secondBody.node as? SKSpriteNode else {return}
            explosion(targetNode: targetNode, isSmall: true)
            targetNode.removeFromParent()
            
            firstBody.node?.removeFromParent()
            
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.missile && secondBody.categoryBitMask == PhysicsCategory.boss {
            print("missile and boss!")
            
            // 미사일 부딪힌 부분에서 폭발
            
            guard let targetNode = firstBody.node as? SKSpriteNode else {return}
            explosion(targetNode: targetNode, isSmall: true)
            targetNode.removeFromParent()
            
            guard let boss = boss else {return}
            boss.shootCount += 1
            print(boss.shootCount)
            
            //            if boss.shootCount >= (boss.maxHP / 2) {
            //                let damageTexture = boss.createDamageTexture()
            //                boss.addChild(damageTexture)
            //            }
            
            if boss.shootCount > boss.maxHP {
                print("boss has defeated")
                
                explosion(targetNode: targetNode, isSmall: false)
                secondBody.node?.removeFromParent()
                self.boss = nil
                self.hud.score += 100
                self.bossNumber -= 1
                isBossOnScreen = false
                bossFireTimer1.invalidate()
                bossFireTimer2.invalidate()
                
                //보스가 남아있으면 스테이지 클리어, 없으면 게임 클리어
                
                if bossNumber > 0 {
                    stageClear()
                } else {
                    gameClear()
                }
                
                
            } else if boss.shootCount >= Int(Double(boss.maxHP) * 0.6) {
                print("boss HP left is 40%")
                
                //2단계 -> 3단계
                if boss.bossState == .secondStep {
                    boss.bossState = .thirdStep
                    
                    bossFireTimer2 = setTimer(interval: 3.0, function: bossCircleFire(bPoint:))
                } else { return }
                
            } else if boss.shootCount >= Int(Double(boss.maxHP) * 0.2) {
                print("boss Hp left is 80%")
                
                //1단계 -> 2단계
                if boss.bossState == .firstStep {
                    boss.bossState = .secondStep
                    
                    bossFireTimer1 = setTimer(interval: 2.0, function: self.bossFire)
                    
                } else {return}
            }
            
            
            
        }
        
        if hud.livesArray.isEmpty {
            gameover()
        }
        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isBossOnScreen {
            return
        } else if self.hud.score >= 350 {
            self.boss = Boss(screenSize: self.size, level: 2)
            guard let boss = boss else {return}
            self.addChild(boss)
            boss.appear()
            
            isBossOnScreen = true
        } else if self.hud.score >= 50 {
            if bossNumber == 2 {
                self.boss = Boss(screenSize: self.size, level: 1)
                guard let boss = boss else {return}
                self.addChild(boss)
                boss.appear()
                
                isBossOnScreen = true
            }  else {return}
         
        }
      
        
    }
    
    
    
}
