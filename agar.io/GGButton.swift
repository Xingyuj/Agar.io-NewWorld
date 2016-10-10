//
//  GGButton.swift
//  agar.io
//
//  Created by lld on 15/10/12.
//  Copyright © 2015年 Big Nerd Ranch. All rights reserved.
//

import SpriteKit

class GGButton: SKNode {
    var defaultButton: SKSpriteNode
    var activeButton: SKSpriteNode
    
    init(defaultButtonImage: String, activeButtonImage: String) {
        defaultButton = SKSpriteNode(imageNamed: defaultButtonImage)
        activeButton = SKSpriteNode(imageNamed: activeButtonImage)
        activeButton.hidden = true
        
        super.init()
        
        userInteractionEnabled = true
        addChild(defaultButton)
        addChild(activeButton)
    }
    
    
    /**
    Required so XCode doesn't throw warnings
    */
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            if (CGRectContainsPoint(defaultButton.frame, location)) {
                if(activeButton.hidden == false) {
                    activeButton.hidden = true
                    defaultButton.hidden = false
                } else {
                    activeButton.hidden = false
                    defaultButton.hidden = true
                }

            }
        }
    }
    
//    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        let touch = touches.first! as? UITouch
//        let location: CGPoint = touch!.locationInNode(self)
//        
//        if defaultButton.containsPoint(location) {
//            if(activeButton.hidden == false) {
//                activeButton.hidden = true
//                defaultButton.hidden = false
//            } else {
//                activeButton.hidden = true
//                defaultButton.hidden = false
//            }
//        }
//    }
    
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        let touch = touches.first! as? UITouch
//        let location: CGPoint = touch!.locationInNode(self)
//        
//        activeButton.hidden = true
//        defaultButton.hidden = false
//    }
}
