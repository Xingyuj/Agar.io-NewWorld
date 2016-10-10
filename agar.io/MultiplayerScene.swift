//
//  multipleConnect.swift
//  agar.io
//
//  Created by Xingyuji on 13/10/2015.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion
import MultipeerConnectivity

class MultiplayerScene: SKScene, SKPhysicsContactDelegate{
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
    
    // color
    let color = [SKColor.blackColor(),SKColor.blueColor(),SKColor.redColor(),SKColor.yellowColor()]
    // skins
    let skins = ["china","usa"]
    
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
    
    
    //map size
    let mapWidth:CGFloat = 2000
    let mapHeight:CGFloat = 2000
    
    //
    var mpcHandler: MPCHandler = MPCHandler()
    var appDelegate: AppDelegate = AppDelegate()
    
    struct PhysicsCategory{
        static let None             :UInt32 = 0
        static let All              :UInt32 = 0xFFFFFFFF
        static let VerticalEdge     :UInt32 = 0b000001
        static let HorizontalEdge   :UInt32 = 0b000010
        static let Player           :UInt32 = 0b000100
        static let Food             :UInt32 = 0b001000
        static let Virus            :UInt32 = 0b010000
    }

    init(size: CGSize, name: String?, accelerometer: Bool, appDelegaye: AppDelegate) {
        if(name != nil) {
            player.playerName = name!
        }
        self.accelerometer = accelerometer
        super.init(size: size)
        appDelegate = appDelegaye
        mpcHandler = appDelegate.mpcHandler
        //发送 data
       
        
        
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
        mpcHandler.delegate = self
        
        // send initial player data
   
        var message = PlayerInfo(message: Message(messageType: MessageType.PlayerInfo), player: player)
        var data = NSData(bytes: &message, length: sizeof(PlayerInfo))
        mpcHandler.sendData(data)
        
        // send the scene data
//        var message1 = SceneSet(message: Message(messageType: MessageType.SceneSet), foodList: modController.foodsList, viruseList: modController.viruseList)
//        data = NSData(bytes:  &message1, length: sizeof(SceneSet))
//        mpcHandler.sendData(data)
    }
    
    func setupMod(){
        //foodController
        modController.setupFrameSize(UInt32(self.frame.width), height: UInt32(self.frame.height))
        let initFoods = modController.createFoodsForInit()
        let initViruse = modController.createViruseForInit()
        for food in initFoods{
            self.addChild(food)
        }
        for viruse in initViruse{
            self.addChild(viruse)
        }
    }
    
    func setupMod(viruseList: [Viruse], foodList: [Food]){
        //foodController
        modController.setupFrameSize(UInt32(self.frame.width), height: UInt32(self.frame.height))
        let initFoods = modController.createFoodsForInit()
        let initViruse = modController.createViruseForInit()
        for food in initFoods{
            self.addChild(food)
        }
        for viruse in initViruse{
            self.addChild(viruse)
        }
        
        modController.foodsList = foodList
        for food in foodList {
            self.addChild(food)
        }
        modController.viruseList = viruseList
        for viruse in viruseList{
            self.addChild(viruse)
        }
        
    }
    
    func setupPlayer(){
        for cell in player.cellsList{
            cell.position = self.getRandomPosition()
            cell.strokeColor = SKColor.blackColor()
            cell.lineWidth = 1
            cell.label.text = player.playerName
            cell.label.fontSize = cell.frame.size.height / 9;
            cell.label.fontColor = SKColor.whiteColor()
            cell.label.zPosition = 6
            
            cell.physicsBody = SKPhysicsBody(circleOfRadius: cell.cellStartRadius)
            cell.physicsBody!.affectedByGravity = false
            cell.physicsBody!.mass = 1.0
            
            //collision
            cell.physicsBody!.usesPreciseCollisionDetection = true
            cell.physicsBody!.dynamic = true
            cell.physicsBody!.categoryBitMask = PhysicsCategory.Player
            cell.physicsBody!.contactTestBitMask = PhysicsCategory.Food | PhysicsCategory.VerticalEdge | PhysicsCategory.HorizontalEdge | PhysicsCategory.Virus
            cell.physicsBody!.collisionBitMask = PhysicsCategory.HorizontalEdge | PhysicsCategory.VerticalEdge
            
            if(player.playerName != nil) {
                if(skins.contains(player.playerName!)) {
                    cell.fillColor = SKColor.whiteColor()
                    cell.fillTexture = SKTexture(imageNamed: "\(player.playerName!).png")
                } else {
                    cell.fillColor = color[Int(arc4random_uniform(UInt32(color.count)))]
                }
            } else {
                cell.fillColor = color[Int(arc4random_uniform(UInt32(color.count)))]
            }
            
            self.addChild(cell)
            
        }

    }
    
    func getRandomPosition()->CGPoint{
        return CGPoint(
            x: Int(arc4random_uniform(UInt32(mapWidth))),
            y: Int(arc4random_uniform(UInt32(mapHeight)))
        )
    }
    
    func setupCamera(){
        //camera related
        self.addChild(camer)
        self.camera = camer
        camer.position = player.centralCell!.position
        camer.xScale = 1.0
        camer.yScale = 1.0
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
        //HUD sub View
        hudSubView.ignoresSiblingOrder = true
        hudSubView.backgroundColor = SKColor(red: 0.0, green: 0, blue: 0, alpha: 0.0)
        hudSubView.frame = CGRect(x: 0,y:0,width: view.frame.width, height: view.frame.height)
        
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
    
    func createFood(x: CGFloat, y: CGFloat) {
        let food = Food(position: CGPointMake(x, y))
        self.addChild(food)
        food.physicsBody!.categoryBitMask = PhysicsCategory.Food
        food.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        food.physicsBody!.collisionBitMask = PhysicsCategory.None
    }
    
    func createVirus(x: CGFloat, y: CGFloat, radius: CGFloat) {
        let viruse = Viruse(radius: radius, position: CGPointMake(x, y))
        self.addChild(viruse)
        viruse.physicsBody!.categoryBitMask = PhysicsCategory.Virus
        viruse.physicsBody!.contactTestBitMask = PhysicsCategory.Food | PhysicsCategory.Player
        viruse.physicsBody!.collisionBitMask = PhysicsCategory.None

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
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch contactMask{
            
        case PhysicsCategory.Player | PhysicsCategory.Food:
            let food:SKShapeNode
            //remove mob
            if contact.bodyA.categoryBitMask == PhysicsCategory.Player{
                food = contact.bodyB.node as! SKShapeNode
                food.removeFromParent()
                let cell = contact.bodyA.node as! SKShapeNode
                if(cell.xScale <= 10.0){
                    cell.runAction(SKAction.scaleTo(cell.xScale + 0.1, duration: 0.3))
                }
            }else{
                food = contact.bodyA.node as! SKShapeNode
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
            let newFood = modController.createFood()
            
             //send the data to others
            var message = FoodInfo(message: Message(messageType: MessageType.FoodInfo), food: newFood, x:                  food.position.x, y: food.position.y)
            var data = NSData(bytes: &message, length: sizeof(FoodInfo))
            mpcHandler.sendData(data)
            
        case PhysicsCategory.Player | PhysicsCategory.Virus:
            // send the player encountering viruse data to others
            var message = EncounterViruse(message: Message(messageType: MessageType.EncounterViruse), player: player)
            var data = NSData(bytes: &message, length: sizeof(EncounterViruse))
            mpcHandler.sendData(data)
            
            gameOverTapped()

        case PhysicsCategory.Player | PhysicsCategory.HorizontalEdge:
            for cell in player.cellsList{
                cell.speedY = -cell.speedY
            }
        case PhysicsCategory.Player | PhysicsCategory.VerticalEdge:
            for cell in player.cellsList{
                cell.speedX = -cell.speedX
            }
            
        default:
            return
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
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
            cell.position = CGPointMake(cell.position.x - cell.speedX, cell.position.y + cell.speedY)
        }
        camer.position = player.centralCell!.position
    }


}


extension MultiplayerScene:MPCHandlerDelegate{
    
    //receive data
    func peerDisconnected(manager: MPCHandler, peer: MCPeerID) {
        //self.getPlayer(peer).remove();
    }

    func connectedDevicesChanged(manager : MPCHandler, connectedDevices: [String]){
        NSOperationQueue.mainQueue().addOperationWithBlock {
        }
    }
    
    func otherPeerMoved(manager : MPCHandler, axis: String){
        NSOperationQueue.mainQueue().addOperationWithBlock {
            
        }
    }
    
    
    func sceneSet(manager: MPCHandler, scene: SceneSet) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            print(scene)
        }
    }
    
    func foodInfo(manager: MPCHandler, food: Food, x: CGFloat, y: CGFloat) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            let deletedFood = self.nodeAtPoint(CGPointMake(x, y))
            deletedFood.removeFromParent()
            self.addChild(food)
        }
    }
    
    
    func cellInfo(manager: MPCHandler, x: CGFloat, y: CGFloat, size: CGFloat, name: String?) {
        let cell = SKShapeNode(circleOfRadius: size/2)
        cell.position = CGPointMake(x,y)
        cell.strokeColor = SKColor.blackColor()
        cell.lineWidth = 1
        let label = SKLabelNode()
        cell.addChild(label)
        label.text = name
        label.fontSize = cell.frame.size.height / 9;
        label.fontColor = SKColor.whiteColor()
        label.zPosition = 6
        
            if(name != nil) {
            if(skins.contains(player.playerName!)) {
                cell.fillColor = SKColor.whiteColor()
                cell.fillTexture = SKTexture(imageNamed: "\(name!).png")
            } else {
                cell.fillColor = color[Int(arc4random_uniform(UInt32(color.count)))]
            }
        } else {
            cell.fillColor = color[Int(arc4random_uniform(UInt32(color.count)))]
        }
        self.addChild(cell)
    }
}