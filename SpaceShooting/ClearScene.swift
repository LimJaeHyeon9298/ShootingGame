//
//  ClearScene.swift
//  SpaceShooting
//
//  Created by 임재현 on 2023/09/10.
//

import SpriteKit

class ClearScene: SKScene {
    
    override func didMove(to view: SKView) {
        guard let starfield = SKEmitterNode(fileNamed: Particle.starField) else { return }
        starfield.position = CGPoint(x: size.width / 2, y: size.height)
        starfield.zPosition = Layer.starField
        starfield.advanceSimulationTime(30)
        self.addChild(starfield)
        
        let thankLabel = SKLabelNode(text: "Thank you for playing!")
        thankLabel.fontName = "Minercraftory"
        thankLabel.fontSize = 20
        thankLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        thankLabel.zPosition = Layer.hud
        self.addChild(thankLabel)
        
        let homeLabel = SKLabelNode(text: "Touch to home")
        homeLabel.fontName = "Minercraftory"
        homeLabel.fontSize = 15
        homeLabel.position = CGPoint(x: size.width / 2, y: size.height / 4)
        homeLabel.zPosition = Layer.hud
        self.addChild(homeLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let menuscene = MenuScene(size: size)
        let transition = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
        menuscene.scaleMode = .aspectFit
        self.view?.presentScene(menuscene, transition: transition)
    }
}

