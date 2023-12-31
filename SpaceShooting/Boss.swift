//
//  Boss.swift
//  SpaceShooting
//
//  Created by 임재현 on 2023/09/10.
//

import SpriteKit

enum BossState {
    case firstStep
    case secondStep
    case thirdStep
    
}

class Boss: SKSpriteNode {
    
    var screenSize: CGSize!
    var level: Int!
    
    let bossHP: [Int] = [50,70]
    var maxHP: Int!
    var shootCount:Int = 0
    
    //보스 스테이트 머신
    var bossState: BossState! {
        didSet {
            if bossState == .secondStep {
                print(bossState as Any)
                self.run(infiniteMoveRL1)
            } else if bossState == .thirdStep {
                print(bossState as Any)
                self.removeAllActions()
                self.run(infiniteMoveRL2)
                let damageTexture = createDamageTexture()
                self.addChild(damageTexture)
            }
        }
    }
    
    // 애니메이션용 변수
    var infiniteMoveRL1 = SKAction()
    var infiniteMoveRL2 = SKAction()
    
    init(screenSize: CGSize,level:Int) {
        self.screenSize = screenSize
        self.level = level
        self.maxHP = self.bossHP[level - 1]
        let texture = Atlas.gameobject.textureNamed(String(format:"boss%d",level))
        self.bossState = .firstStep
        
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        
        //물리바디
        self.zPosition = Layer.boss
        self.physicsBody = SKPhysicsBody(texture: texture, size: self.size)
        self.physicsBody?.categoryBitMask = PhysicsCategory.boss
        self.physicsBody?.contactTestBitMask = 0
        self.physicsBody?.collisionBitMask = 0
        
        
        self.position.x = screenSize.width / 2
        self.position.y = screenSize.height + texture.size().height
        
        createActions()
        
    }
    
    //출현 애니메이션
    func appear() {
        let duration = 3.0
        let fadeIn = SKAction.moveTo(y: screenSize.height * 0.8, duration: duration)
        run(fadeIn)
    }
    
    // 데미지 표현
    func createDamageTexture() -> SKSpriteNode {
        let texture = Atlas.gameobject.textureNamed(String(format: "bossdamage%d", level))
        let overlay = SKSpriteNode(texture: texture)
        overlay.position = CGPoint(x: 0, y: 0)
        overlay.zPosition = Layer.upper
        overlay.colorBlendFactor = 0.0
        return overlay
    }
    
    // 단계별 애니메이션 작성
    func createActions() {
        
        // 좌우이동 1단계
        let duration1 = 3.0
        let moveRight1 = SKAction.moveTo(x: screenSize.width, duration: duration1)
        let moveCenter1 = SKAction.moveTo(x: screenSize.width / 2, duration: duration1)
        let moveLeft1 = SKAction.moveTo(x: 0, duration: duration1)
        let moveRtoL1 = SKAction.sequence([moveRight1, moveCenter1, moveLeft1, moveCenter1])
        infiniteMoveRL1 = SKAction.repeatForever(moveRtoL1)
        
        // 좌우이동 2단계
        let duration2 = 1.0
        let moveRight2 = SKAction.moveTo(x: screenSize.width, duration: duration2)
        let moveCenter2 = SKAction.moveTo(x: screenSize.width / 2, duration: duration2)
        let moveLeft2 = SKAction.moveTo(x: 0, duration: duration2)
        let moveRtoL2 = SKAction.sequence([moveRight2, moveCenter2, moveLeft2, moveCenter2])
        infiniteMoveRL2 = SKAction.repeatForever(moveRtoL2)
    }
    
    // 미사일 작성
    func createMissile() -> SKSpriteNode {
        let texture = Atlas.gameobject.textureNamed("bossmissile")
        let missile = SKSpriteNode(texture: texture)
        missile.position = self.position
        missile.zPosition = Layer.bossmissile
        missile.physicsBody = SKPhysicsBody(circleOfRadius: missile.size.width / 2)
        missile.physicsBody?.categoryBitMask = PhysicsCategory.bossMissile
        missile.physicsBody?.contactTestBitMask = 0
        missile.physicsBody?.collisionBitMask = 0
        missile.physicsBody?.usesPreciseCollisionDetection = true
        
        return missile
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
