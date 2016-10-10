//
//  HUDScene.swift
//  SpriteWalkthrough
//
//  Created by Wen on 10/10/2015.
//  Copyright © 2015 Wen. All rights reserved.
//

import SpriteKit
import CoreMotion

class HUDScene: SKScene{
    
    //debug
    var debugPlayerNode: SKNode? = nil
    var debugCameraNode: SKNode? = nil
    
    var debugFontName: String = "COURIER"
    var debugFontSize: CGFloat = 14.0
    var debugFontColor: SKColor = SKColor.whiteColor()
    
    var debugPlayerLabel: SKLabelNode = SKLabelNode()
    var debugCameraLabel: SKLabelNode = SKLabelNode()
    var debugLabel: SKLabelNode = SKLabelNode()
    
    //button 
    let button1 = SKSpriteNode(imageNamed:"Button")
    
    //player score board
    let format:String = "%.2f"
    let playerScoreLabel: SKLabelNode = SKLabelNode()
    
    //leader board
    var leaders = [SKLabelNode]()
    // use hash [name:String, score:Int] just update the hash, hash has to be sorted

    var gameScene: GameScene?

    //statistic
    let timeInGameLabel:SKLabelNode = SKLabelNode()
    let currentRankLabel:SKLabelNode = SKLabelNode()
    let highestRanklabel:SKLabelNode = SKLabelNode()
    let foodConsumedLabel:SKLabelNode = SKLabelNode()
    let playerEatenLabel:SKLabelNode = SKLabelNode()
    var playerEaten: Int = 0
    var foodConsumed: Int = 0
    var time: Int = 0
    
    let staColor = SKColor.redColor()
    let staFont = "COURIER"
    let staFontSize:CGFloat = 20.0
    
    override init(size: CGSize){
        super.init(size:size)
        setupDebug()
        setupPlayerScore()
        setupLeaderBoard()
        setupButton()
    }
    
    
    required init(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupGameScene(gameScene: GameScene){
        self.gameScene = gameScene
    }
    
    func setupButton() {
        self.addChild(button1)
        button1.alpha = 0.3
        button1.position = CGPointMake(1000, 200)
        button1.zPosition = 15
        button1.xScale = 1
        button1.yScale = 1
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            if (CGRectContainsPoint(button1.frame, location)) {
                gameScene?.playerSplitCells()
            }
        }
    }

    
    func setupDebug(){
        debugPlayerLabel.fontName = debugFontName
        debugPlayerLabel.fontSize = debugFontSize
        debugPlayerLabel.fontColor = debugFontColor
        debugPlayerLabel.position = CGPoint(x:0, y:0)
        debugPlayerLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        
        debugCameraLabel.fontName = debugFontName
        debugCameraLabel.fontSize = debugFontSize
        debugCameraLabel.fontColor = debugFontColor
        debugCameraLabel.position = CGPoint(x:0, y:10)
        debugCameraLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        
        debugLabel.fontName = debugFontName
        debugLabel.fontSize = debugFontSize
        debugLabel.fontColor = debugFontColor
        debugLabel.position = CGPoint(x:0, y:20)
        debugLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        
        self.addChild(debugPlayerLabel)
        self.addChild(debugCameraLabel)
        self.addChild(debugLabel)
    }

    func setupStatistic(){
        timeInGameLabel.fontName = staFont
        timeInGameLabel.fontSize = staFontSize
        timeInGameLabel.fontColor = staColor
        timeInGameLabel.position = CGPoint(x:0,y:60)
        timeInGameLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        timeInGameLabel.text = "Time in game = 0 s"
        self.addChild(timeInGameLabel)
        
        currentRankLabel.fontName = staFont
        currentRankLabel.fontSize = staFontSize
        currentRankLabel.fontColor = staColor
        currentRankLabel.position = CGPoint(x:0,y:80)
        currentRankLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        currentRankLabel.text = "Current rank = 1"
        self.addChild(currentRankLabel)
        
        highestRanklabel.fontName = staFont
        highestRanklabel.fontSize = staFontSize
        highestRanklabel.fontColor = staColor
        highestRanklabel.position = CGPoint(x:0,y:100)
        highestRanklabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        highestRanklabel.text = "Highest rank = 1"
        self.addChild(highestRanklabel)
        
        foodConsumedLabel.fontName = staFont
        foodConsumedLabel.fontSize = staFontSize
        foodConsumedLabel.fontColor = staColor
        foodConsumedLabel.position = CGPoint(x:0,y:120)
        foodConsumedLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        foodConsumedLabel.text = "Food consumed = 0"
        self.addChild(foodConsumedLabel)
        
        playerEatenLabel.fontName = staFont
        playerEatenLabel.fontSize = staFontSize
        playerEatenLabel.fontColor = staColor
        playerEatenLabel.position = CGPoint(x:0,y:140)
        playerEatenLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        playerEatenLabel.text = "Player eaten = 0"
        self.addChild(playerEatenLabel)
    }
    
    func uploadPlayerEaten() {
        playerEaten++
        playerEatenLabel.text = "Player eaten = \(playerEaten)"
    }
    
    func uploadFoodConsumed() {
        foodConsumed++
        foodConsumedLabel.text = "Food consumed = \(foodConsumed)"
    }
    
    func uploadTime() {
        time++
        timeInGameLabel.text = "Time in game = \(time) s"
    }

    func setupPlayerScore(){
        playerScoreLabel.text = "Score: 0"
        playerScoreLabel.fontName = "Open Sans"
        playerScoreLabel.fontSize = CGFloat(40)
        playerScoreLabel.fontColor = SKColor.whiteColor()
        playerScoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame),y:CGRectGetMaxY(self.frame)-50)
        playerScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        self.addChild(playerScoreLabel)
    }
    
    func setupLeaderBoard(){
        //the hash is already
        let example =
        [
            "player 1": 12,
            "some player":24,
            "random gay": 0
        ]
        let title:SKLabelNode = SKLabelNode()
        title.text = "Leaderboard"
        title.fontName = "Code"
        title.fontSize = CGFloat(24)
        title.fontColor = SKColor.whiteColor()
        title.position = CGPoint(
            x:CGRectGetMaxX(self.frame)-70,
            y:CGRectGetMaxY(self.frame)-50)
        
        self.addChild(title)
        for (index,value) in example.enumerate(){
            //print(index)
            //print(value)
            //print(value.0)
            //print(value.1)
            
            let temp:SKLabelNode = SKLabelNode()
            temp.text = "\(value.0): \(value.1)"
            temp.fontName = "Code"
            temp.fontSize = CGFloat(20)
            temp.fontColor = SKColor.whiteColor()
            temp.position = CGPoint(
                x:CGRectGetMaxX(self.frame)-70,
                y:CGRectGetMaxY(self.frame)-CGFloat(50+(index+1)*20))
            
            print(index)   //order of enumerate is weired
            print(value)
            self.addChild(temp)
            leaders.append(temp)
        }
        print(leaders)
    }
    
    override func update(currentTime: NSTimeInterval) {
        if let node = debugPlayerNode{
            debugPlayerLabel.text =
                "Player: " +
                "(x: \(Int(node.position.x)),y: \(Int(node.position.y))), " +
                "(xSize: \(NSString(format: format, node.frame.height)),ySize: \(NSString(format: format, node.frame.width))), " +
            "(xS: \(NSString(format: format,node.xScale)),yS: \(NSString(format:format,node.yScale)))"
            
        }else{
            debugPlayerLabel.text = "Player: (x: nil,y: nil), (xsize: nil, ysize: nil), (xS: nil, yS: nil)"
        }
        
        if let node = debugCameraNode{
            debugCameraLabel.text =
                "Camera: " +
                "(x: \(NSString(format: format, node.position.x)),y: \(NSString(format: format, node.position.y))), " +
            "(xS: \(NSString(format: format,node.xScale)),yS: \(NSString(format:format, node.yScale)))"
        }else{
            debugCameraLabel.text = "Camera: (x: nil,y: nil), (xS: nil, yS: nil)"
        }
        
    }
    
    func setDebugText(text:String){
        debugLabel.text = text
    }
    
    func setPlayerScore(s: Int){
        playerScoreLabel.text = "Score: \(s)"
        
        let temp =
        [
            "dsa":1,
            "asd":2,
            "sss":3
        ]
        updateLeaderBoard(temp)
    }
    
    func updateLeaderBoard( updatedScore:[String:Int]){
        
        for (index,value) in updatedScore.enumerate(){
            leaders[index].text! = "\(value.0): \(value.1)"
        }
    }
    
    
}