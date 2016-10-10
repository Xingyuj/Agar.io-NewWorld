//
//  MainMenuScene.swift
//  agar.io
//
//  Created by lld on 15/10/12.
//  Copyright © 2015年 Big Nerd Ranch. All rights reserved.
//

import Foundation
import SpriteKit
import MultipeerConnectivity

class MainMenuScene: SKScene, UITextFieldDelegate , MCBrowserViewControllerDelegate{
    var accelerometer = false
    var single = SKSpriteNode()
    var multiple = SKSpriteNode()
    var textField = UITextField()
    var button: GGButton = GGButton(defaultButtonImage: "off", activeButtonImage: "on")
    var appDelegate: AppDelegate!
    
    override func didMoveToView(view: SKView) {
        
        // add the textField
        //textField = UITextField(frame: CGRectMake(self.size.width/2, self.size.height/2 + 100 , 200, 40))
        textField = UITextField(frame: CGRectMake(180, 80 , 180, 40))
        //textField.center = self.view!.center
        textField.textColor = SKColor.orangeColor()
        textField.placeholder = "Enter your name here";
        textField.backgroundColor = SKColor.whiteColor()
        //        textField.autocorrectionType = UITextAutocorrectionTypeYes;
        //        textField.keyboardType = UIKeyboardTypeDefault;
        //        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.delegate = self;
        self.textField.resignFirstResponder()
        self.view!.addSubview(textField)
        
        // add the accelerometer button
        button.zPosition = 6
        button.xScale = 0.3
        button.yScale = 0.3
        button.position = CGPointMake(self.frame.width / 2 + 150, self.frame.height / 2 + 10)
        addChild(button)
        
        // add the label of accelerometer
        let label = SKLabelNode(fontNamed:"ArialMT")
        label.text = "accelerometer"
        label.fontSize = 50;
        label.fontColor = SKColor.greenColor()
        label.position = CGPointMake(self.frame.width / 2 - 70 , self.frame.height / 2)
        label.zPosition = 6
        self.addChild(label)
        
        // add the background
        let bgImage = SKSpriteNode(imageNamed: "memuBG_meitu.jpg")
        self.addChild(bgImage)
        bgImage.zPosition = 3
        bgImage.position = CGPointMake(self.frame.width/2, self.frame.height/2)
        
        // add the icon of the single player and multiplayer
        single = SKSpriteNode(imageNamed: "singlePlayer.jpg")
        self.addChild(single)
        single.zPosition = 6
        single.position = CGPointMake(self.frame.width/2 - 400, self.frame.height/2)
        single.xScale = 1.5
        single.yScale = 1.5
        
        multiple = SKSpriteNode(imageNamed: "multiplayer.jpg")
        self.addChild(multiple)
        multiple.zPosition = 6
        multiple.position = CGPointMake(self.frame.width/2 + 400, self.frame.height/2)
        multiple.xScale = 1.5
        multiple.yScale = 1.5
        
        if textField.hidden == true {
            textField.hidden = false
        }
        
        appDelegate = UIApplication.sharedApplication().delegate as!
        AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayerName(UIDevice.currentDevice().name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(true)
        
    }
    
    
    
    func singleSceneTapped() {
        if(button.activeButton.hidden == false) {
            accelerometer = true
        } else {
            accelerometer = false
        }
        print(textField.text)
        let myScene = GameScene(size:self.size, name: textField.text, accelerometer: accelerometer )
        myScene.scaleMode = scaleMode
        let reveal = SKTransition.doorwayWithDuration(1.5)
        self.view?.presentScene(myScene, transition: reveal)
    }
    
    func multipleSceneTapped() {
        
        if appDelegate.mpcHandler.session != nil {
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            let viewController = self.view?.window?.rootViewController
            viewController!.presentViewController(appDelegate.mpcHandler.browser, animated: true, completion: nil)
        }
        
    }

    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            if (CGRectContainsPoint(single.frame, location)) {
                textField.hidden = true
                singleSceneTapped()
            }
            if (CGRectContainsPoint(multiple.frame, location)) {
                textField.hidden = true
                multipleSceneTapped()
            }

        }
    }
    
    func accelerometerSwitch() -> Void{
        if accelerometer == true
        {
            accelerometer = false
        }
        else{
            accelerometer = true
        }
        
    }
    func textFieldShouldReturn(userText: UITextField!) -> Bool {
        userText.resignFirstResponder()
        return true;
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        
        if(button.activeButton.hidden == false) {
            accelerometer = true
        } else {
            accelerometer = false
        }
        let myScene = MultiplayerScene(size:self.size, name: textField.text, accelerometer: accelerometer, appDelegaye: appDelegate)
        myScene.scaleMode = scaleMode
        let reveal = SKTransition.doorwayWithDuration(1.5)
        self.view?.presentScene(myScene, transition: reveal)
        
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
}