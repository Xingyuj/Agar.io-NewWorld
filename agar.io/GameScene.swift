//
//  GameScene.swift
//  agar.io
//
//  Created by F on 12/10/2015.
//  Copyright (c) 2015 UniMelb. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate{
        
    //logic attributes
    var player = Player(playerName: "Player")
    var modController = ModController()
    
    //camerate related
    let camer:SKCameraNode = SKCameraNode()
    let hudSubView = SKView()
    let hudScene = HUDScene(size: CGSizeMake(1024, 768))
    var bgm:SKAudioNode = SKAudioNode()
    
    // create virtual stick
    var stickActive:Bool = false
    let base = SKSpriteNode(imageNamed: "Base.png")
    let ball = SKSpriteNode(imageNamed: "Ball.png")
    /*-----------------------------------------------------------------*/
    
    // Sensor
    var accelerometer = false
    let motionManager: CMMotionManager = CMMotionManager()
    let ay = Vector3(x: 0.63, y: 0.0, z: -0.92)
    let az = Vector3(x: 0.0, y: 1.0, z: 0.0)
    let ax = Vector3.crossProduct(Vector3(x: 0.0, y: 1.0, z: 0.0),
        right: Vector3(x: 0.63, y: 0.0, z: -0.92)).normalized()
    
    let steerDeadZone = CGFloat(0.15)
    
    let blend = CGFloat(0.2)
    var lastVector = Vector3(x: 0, y: 0, z: 0)
    
    //bodyType
    enum BodyType:UInt32 {
        case cell = 1
        case levelGround = 2
        case verticalGround = 4
    }
    //map size
    let mapWidth:CGFloat = 2000
    let mapHeight:CGFloat = 2000
    

    // timer
    var timer = 0
    
    //create enemy
    var enemy1 = SKShapeNode(circleOfRadius: 20)
    var enemy2 = SKShapeNode(circleOfRadius: 20)
    var enemies: [SKShapeNode] = [SKShapeNode]()
    var modList: [SKShapeNode] = [SKShapeNode]()
    
    //PhysicsCategory for collision handling
    struct PhysicsCategory{
        static let None             :UInt32 = 0
        static let All              :UInt32 = 0xFFFFFFFF
        static let VerticalEdge     :UInt32 = 0b000001
        static let HorizontalEdge   :UInt32 = 0b000010
        static let Player           :UInt32 = 0b000100
        static let Food             :UInt32 = 0b001000
        static let Virus            :UInt32 = 0b010000
        static let Enemy            :UInt32 = 0b100000
    }

    init(size: CGSize, name: String?, accelerometer: Bool) {
        if(name != nil) {
            player.playerName = name!
        }
        self.accelerometer = accelerometer
        self.player.accelerometer = accelerometer
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //Override function
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        //setups
        setupPlayer()
        setupAudio()
        setupCamera()
        setupMod()
        setupBoundary()
        setupVirtualStick()
        setupHUD(view)
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates()
        motionManager.startDeviceMotionUpdates()
    }
    
//    override func update(currentTime: CFTimeInterval) {
//        if(accelerometer) {
//            if motionManager.accelerometerData != nil {
//                moveCircleFromAcceleration()
//            }
//            
//        }
//        if motionManager.deviceMotion != nil{
//            if motionManager.deviceMotion!.attitude.roll < 1.5 {
//                self.backgroundColor = SKColor.whiteColor()
//            } else {
//                self.backgroundColor = SKColor.blackColor()
//            }
//        }
//        
//        for cell in player.cellsList{
//            cell.childModifySpeed()
//        }
//        
//        for cell in player.cellsList{
//            cell.position = CGPointMake(cell.position.x - cell.speedX, cell.position.y + cell.speedY)
//        }
//        camer.position = player.centralCell!.position
//        
//        player.checkMerge()
//    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        ball.alpha = 0.4
        base.alpha = 0.4
        
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            player.lastTouch = location
            if accelerometer != true {
                stickActive = true
                base.position = location
                ball.position = location
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in (touches ) {
            player.lastTouch = touch.locationInNode(self)
            let location = touch.locationInNode(self)
            if accelerometer != true {
                if (stickActive == true) {
                    
                    let v = CGVector(dx: location.x - base.position.x, dy:  location.y - base.position.y)
                    let angle = atan2(v.dy, v.dx)
                    
                    let length:CGFloat = base.frame.size.height / 2
                    
                    let xDist:CGFloat = sin(angle - 1.57079633) * length
                    let yDist:CGFloat = cos(angle - 1.57079633) * length
                    
                    
                    if (CGRectContainsPoint(base.frame, location)) {
                        
                        ball.position = location
                        
                    } else {
                        
                        ball.position = CGPointMake( base.position.x - xDist, base.position.y + yDist)
                        
                    }
                    let multiplier:CGFloat = 300
                    
                    for cell in player.cellsList{
                        //TODO according to the size to change the speed
                        cell.speedX = sin(angle - 1.57079633) * multiplier * (1/cell.frame.width)
                        cell.speedY = cos(angle - 1.57079633) * multiplier * (1/cell.frame.width)
                    }
                }
            }
        }

    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //player.touchOn = false
        if accelerometer != true {
            if (stickActive == true) {
                
                let move:SKAction = SKAction.moveTo(base.position, duration: 0.2)
                move.timingMode = .EaseOut
                
                ball.runAction(move)
                
                let fade:SKAction = SKAction.fadeAlphaTo(0, duration: 0.2)
                
                ball.runAction(fade)
                base.runAction(fade)
            }
        }
    }
    /*-----------------------------------------------------------------*/
    func setupCamera(){
        //camera related
        self.addChild(camer)
        self.camera = camer
        camer.position = player.centralCell!.position
        camer.xScale = 0.3
        camer.yScale = 0.3
    }
    
    func setupPlayer(){
        self.addChild(player.createInitCell(getRandomPosition()))
    }
    
    func setupMod(){
        //foodController
        modController.setupFrameSize(UInt32(mapWidth), height: UInt32(mapHeight))
        let initFoods = modController.createFoodsForInit()
        let initViruse = modController.createViruseForInit()
        for food in initFoods{
            //collision
            food.physicsBody!.categoryBitMask = PhysicsCategory.Food
            food.physicsBody!.contactTestBitMask = PhysicsCategory.Player
            food.physicsBody!.collisionBitMask = PhysicsCategory.None
            self.addChild(food)
        }
        for viruse in initViruse{
            viruse.physicsBody!.categoryBitMask = PhysicsCategory.Virus
            viruse.physicsBody!.contactTestBitMask = PhysicsCategory.Food | PhysicsCategory.Player
            viruse.physicsBody!.collisionBitMask = PhysicsCategory.None
            self.addChild(viruse)
        }
    }
    
    func setupAudio(){
        //audio
        let n = Int(arc4random_uniform(2))
        switch n{
        case 0:
            bgm = SKAudioNode(fileNamed: "mario.mp3")
        case 1:
            bgm = SKAudioNode(fileNamed: "underworld.mp3")
        default:
            bgm = SKAudioNode(fileNamed: "mario.mp3")
        }
        
        bgm.autoplayLooped = true
        self.addChild(bgm)
    }
    
    func setupHUD(view: SKView){
        hudScene.setupGameScene(self)
        //HUD sub View
        hudSubView.ignoresSiblingOrder = true
        hudSubView.backgroundColor = SKColor(red: 0.0, green: 0, blue: 0, alpha: 0.0)
        hudSubView.frame = CGRect(x: 0,y:0,width: view.frame.width, height: view.frame.height)  //dont know why is this
        
        //HUD scene
        hudScene.scaleMode = .AspectFit
        hudScene.backgroundColor = SKColor(red: 0, green: 0, blue: 0.0, alpha: 0.0)
        //hudScene.s
        view.addSubview(hudSubView)
        hudSubView.presentScene(hudScene)
        
        hudScene.setDebugText(
            " hud scene (\(hudScene.size.width), \(hudScene.size.height))," +
            " sub view (\(hudSubView.frame.width) ,\(hudSubView.frame.height))")
    }
    
    func getRandomPosition()->CGPoint{
        return CGPoint(
            x: Int(arc4random_uniform(UInt32(mapWidth))),
            y: Int(arc4random_uniform(UInt32(mapHeight)))
        )
    }
    /*-----------------------------------------------------------------*/
    func addSplitCellsToScene(){
        let splitCells = player.splitCells()
        for sCell in splitCells{
            self.addChild(sCell)
        }
    }
    
    
    /*-----------------------------------------------------------------*/
    
    func setupBoundary() {
        let bot = SKShapeNode(rectOfSize: CGSize(width: mapWidth, height: 10))
        bot.position = CGPointMake(mapWidth/2, 0)
        bot.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(mapWidth, 10))
        bot.physicsBody!.dynamic = false
        bot.physicsBody!.categoryBitMask = PhysicsCategory.HorizontalEdge
        self.addChild(bot)
        
        let right = SKShapeNode(rectOfSize: CGSize(width: 10, height: mapHeight))
        right.position = CGPointMake(mapWidth, mapHeight/2)
        right.strokeColor = SKColor.orangeColor()
        right.fillColor = SKColor.orangeColor()
        right.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(10, mapHeight))
        right.physicsBody!.dynamic = false
        right.physicsBody!.categoryBitMask = PhysicsCategory.VerticalEdge
        right.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        self.addChild(right)
        
        let top = SKShapeNode(rectOfSize: CGSize(width: mapWidth, height: 10))
        top.position = CGPointMake(mapWidth/2, mapHeight)
        top.strokeColor = SKColor.orangeColor()
        top.fillColor = SKColor.orangeColor()
        top.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(mapWidth, 10))
        top.physicsBody!.dynamic = false
        top.physicsBody!.categoryBitMask = PhysicsCategory.HorizontalEdge
        self.addChild(top)
        
        let left = SKShapeNode(rectOfSize: CGSize(width: 10, height: mapHeight))
        left.position = CGPointMake(0, mapHeight/2)
        left.strokeColor = SKColor.orangeColor()
        left.fillColor = SKColor.orangeColor()
        left.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(1, mapHeight))
        left.physicsBody!.dynamic = false
        left.physicsBody!.categoryBitMask = PhysicsCategory.VerticalEdge
        left.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        self.addChild(left)

    }
    
    func setupVirtualStick() {
        self.addChild(base)
        base.position = CGPointMake(500,200)
        base.zPosition = 5
        self.addChild(ball)
        ball.position = base.position
        ball.zPosition = 6
        // set the scale of the joystick
        base.xScale = 0.3
        base.yScale = 0.3
        ball.xScale = 0.3
        ball.yScale = 0.3
        base.alpha = 0
        ball.alpha = 0

    }
    
    func moveCircleFromAcceleration() {
        var accel2D = CGPoint.zero
        
        if motionManager.accelerometerData == nil { print("no acceleration data yet"); return
        }
        var raw = Vector3(
            x: CGFloat(motionManager.accelerometerData!.acceleration.x), y: CGFloat(motionManager.accelerometerData!.acceleration.y), z: CGFloat(motionManager.accelerometerData!.acceleration.z))
        accel2D.x = Vector3.dotProduct(raw, right: az)
        accel2D.y = Vector3.dotProduct(raw, right: ax)
        accel2D.normalize()
        
        if abs(accel2D.x) < steerDeadZone { accel2D.x = 0
        }
        if abs(accel2D.y) < steerDeadZone { accel2D.y = 0
        }
        
        let multiplier:CGFloat = 300
        
        let angle = atan2(accel2D.y, accel2D.x)
        
        for cell in player.cellsList{
            // TODO change the speed according to the size
            cell.speedX = sin(angle - 1.57079633) * multiplier * (1/cell.frame.width)
            cell.speedY = cos(angle - 1.57079633) * multiplier * (1/cell.frame.width)
        }
    }
    
    func gameOverTapped() {
        let sizeRect = UIScreen.mainScreen().bounds
        let width = sizeRect.size.width * UIScreen.mainScreen().scale
        let height = sizeRect.size.height * UIScreen.mainScreen().scale
        let myScene =
        MainMenuScene(size:CGSize(width: width, height: height))
        myScene.scaleMode = scaleMode
        let reveal = SKTransition.doorwayWithDuration(1.5)
        self.view?.presentScene(myScene, transition: reveal)
        hudScene.hidden = true
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch contactMask{
            
        case PhysicsCategory.Player | PhysicsCategory.Food:
            hudScene.uploadFoodConsumed()
            //remove mob
            if contact.bodyA.categoryBitMask == PhysicsCategory.Player{
                let food = contact.bodyB.node as! SKShapeNode
                food.removeFromParent()
                let cell = contact.bodyA.node as! SKShapeNode
                if(cell.xScale <= 10.0){
                    cell.runAction(SKAction.scaleTo(cell.xScale + 0.1, duration: 0.3))
                }
            }else{
                let food = contact.bodyA.node as! SKShapeNode
                food.removeFromParent()
            }
            //update player
            player.foodEaten += 1
            hudScene.setPlayerScore(player.foodEaten)
            
            //update camera & animation
            camer.runAction(SKAction.scaleTo(camer.xScale + 0.01, duration: 0.3))
            
            //sound effect
            runAction(SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false))
            
            //spawn new food
            modController.createFood()
            
        case PhysicsCategory.Player | PhysicsCategory.Virus:
            gameOverTapped()
            
        case PhysicsCategory.Player | PhysicsCategory.HorizontalEdge:    
            for cell in player.cellsList{
                cell.speedY = -cell.speedY
            }
        case PhysicsCategory.Player | PhysicsCategory.VerticalEdge:
            for cell in player.cellsList{
                cell.speedX = -cell.speedX
            }
        case PhysicsCategory.Player | PhysicsCategory.Player:
            for cell in player.cellsList{
                cell.speedX = -cell.speedX*0.5
                cell.speedY = -cell.speedY*0.5
            }
            break;
        case PhysicsCategory.Enemy | PhysicsCategory.Player:
            if contact.bodyA.categoryBitMask == PhysicsCategory.Enemy{
                let enemy = contact.bodyA.node as! SKShapeNode
                let player = contact.bodyB.node as! SKShapeNode
                
                if enemy.frame.width * 0.9 > player.frame.width{
                    gameOverTapped()
                }
                if player.frame.width * 0.9 > enemy.frame.width{
                    hudScene.uploadPlayerEaten()
                    var diff = player.xScale + enemy.xScale
                    if(diff > 25.0){ diff = 25.0 - player.xScale } else {diff = enemy.xScale}
                    player.runAction(SKAction.scaleTo(player.xScale + diff, duration: 0.4))
                    enemy.removeFromParent()
                }
                
            }else{
                let enemy = contact.bodyB.node as! SKShapeNode
                let player = contact.bodyA.node as! SKShapeNode
                
                if enemy.frame.width * 0.9 > player.frame.width{
                    gameOverTapped()
                }
                if player.frame.width * 0.9 > enemy.frame.width{
                    var diff = player.xScale + enemy.xScale
                    if(diff > 25.0){ diff = 25.0 - player.xScale } else {diff = enemy.xScale}
                    player.runAction(SKAction.scaleTo(player.xScale + diff, duration: 0.4))
                    enemy.removeFromParent()
                }
            }
            break;
            
        case PhysicsCategory.Enemy | PhysicsCategory.Player:
            if(contact.bodyA.categoryBitMask == PhysicsCategory.Enemy){
                let enemy = contact.bodyA.node as! SKShapeNode
                let food = contact.bodyB.node as! SKShapeNode
                
                food.removeFromParent()
                if(enemy.xScale <= 25.0){
                   enemy.runAction(SKAction.scaleTo(enemy.xScale + 0.1, duration: 0.4))
                }
            }else{
                let enemy = contact.bodyB.node as! SKShapeNode
                let food = contact.bodyA.node as! SKShapeNode
                
                food.removeFromParent()
                if(enemy.xScale <= 25.0){
                    enemy.runAction(SKAction.scaleTo(enemy.xScale + 0.1, duration: 0.4))
                }
            }
        default:
            return
        }
    }


    override func update(currentTime: CFTimeInterval) {
        timer++
        if(timer >= 60) {
            hudScene.uploadTime()
            timer == 0
        }
        
        if(accelerometer) {
            if motionManager.accelerometerData != nil {
                moveCircleFromAcceleration()
            }
            
        }
        
        if motionManager.deviceMotion != nil{
            if motionManager.deviceMotion!.attitude.roll < 1.5 {
                self.backgroundColor = SKColor.whiteColor()
            } else {
                self.backgroundColor = SKColor.blackColor()
            }
        }
        
        for cell in player.cellsList{
            cell.childModifySpeed()
        }
        
        for cell in player.cellsList{
            cell.position = CGPointMake(cell.position.x - cell.speedX, cell.position.y + cell.speedY)
        }
        camer.position = player.centralCell!.position
        player.checkMerge()
        
    }
    
    func playerSplitCells(){
        let splitCells = player.splitCells()
        for sCell in splitCells{
            self.addChild(sCell)
        }
    }

}
