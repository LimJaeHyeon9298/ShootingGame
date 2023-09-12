//
//  Constatns.swift
//  SpaceShooting
//
//  Created by 임재현 on 2023/09/09.
//

import SpriteKit


struct Particle {
    static let starField = "starField"
    static let playerThruster = "PlayerThruster"
    static let enemyThruster = "EnemyThruster"
    static let explosion = "Explosion"
    static let hit = "Hit"
    
    
}

struct Layer {
    static let sub: CGFloat = -0.1
    static let upper:CGFloat = 0.1
    static let starField: CGFloat = 0
    static let meteor:CGFloat = 1
    static let playerMissile:CGFloat = 10
    static let player: CGFloat = 11
    static let enemy: CGFloat = 12
    static let hud: CGFloat = 30
    static let bossmissile:CGFloat = 14
    static let boss: CGFloat = 15
    static let item: CGFloat = 13
    static let gameover:CGFloat = 40
}


struct Atlas {
    static let gameobject = SKTextureAtlas(named: "GameObjects")
}

struct PhysicsCategory {
    static let player: UInt32 = 0x1 << 0
    static let shield: UInt32 = 0x1 << 1
    static let missile : UInt32 = 0x1 << 2
    static let enemy : UInt32 = 0x1 << 3
    static let boss : UInt32 = 0x1 << 4
    static let bossMissile : UInt32 = 0x1 << 5
    static let meteor : UInt32 = 0x1 << 6
    static let item: UInt32 = 0x1 << 7
  
}

struct BGM {
    static let title = "bgmTitle.mp3"
    static let main = "bgmMain.mp3"
}

struct SoundFx {
    static let item = SKAction.playSoundFileNamed("fxItem.mp3", waitForCompletion: false)
    static let explosion = SKAction.playSoundFileNamed("fxExplosion.mp3", waitForCompletion: false)
    static let bossFire = SKAction.playSoundFileNamed("fxBossFire.mp3", waitForCompletion: false)
    static let playerFire = SKAction.playSoundFileNamed("fxPlayerFire.mp3", waitForCompletion: false)
}
