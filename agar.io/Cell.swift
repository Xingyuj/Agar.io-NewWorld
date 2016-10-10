//
//  Cell.swift
//  agar.io
//
//  Created by F on 2/10/2015.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

import Foundation
import SpriteKit

struct SplitInfo {
    var parentCell: Cell
    var splitTime: Double
    var timer: NSTimer
}
class Cell: Disk {
    let ejectSpeed: CGFloat = 20
    let secToMerge: Double = 5.0
    let cellStartRadius : CGFloat = 20
    var cellMaxSpeed : CGFloat = 50
    var label : SKLabelNode
    var speedX : CGFloat = 0
    var speedY : CGFloat = 0
    var controller: Player?
    var splitInfo : SplitInfo?
    var isMerged = false

   /*--------------------------------------------------------------------------------------*/
    //New Disk
    init(controller : Player, location : CGPoint){
        self.controller = controller
        label = SKLabelNode(fontNamed: "ArialMR")
        super.init(radius: cellStartRadius, position : location)
        self.setCellLabel(controller.playerName!)
        self.addChild(label)
        self.physicsBody?.collisionBitMask = PhysicsCategory.Player
    }
    
    //Init for copy?
    override init(){
        self.label = SKLabelNode(fontNamed: "ArialMR")
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   /*--------------------------------------------------------------------------------------*/
    private func setCellLabel(userName : String){
        label.text = userName
        label.fontSize = self.frame.size.height / 5
        label.fontColor = SKColor.whiteColor()
        label.zPosition = self.zPosition + 1
    }
    
    override func setPhysicsBody(){
        super.setPhysicsBody()
    }
    
    private func scaleVectorWithLength(length: CGFloat, vector: CGVector) ->CGFloat {
        let lengthVector = sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
        return length/lengthVector
    }
    
    /*--------------------------------------------------------------------------------------*/
    ///split a cell
    func split() ->Cell{
        //Change the radius
        //self.radius = sqrt(self.radius*self.radius/2)
        self.xScale = self.xScale/2
        self.yScale = self.yScale/2
        
        //Copy a same cell
        let splitCell = self.copyCell()
        
        //Set timer
        let timer = NSTimer(timeInterval: 0.5, target: splitCell,
            selector: "mergeToParent", userInfo: nil, repeats: true)
        
        //Set split info
        splitCell.splitInfo = SplitInfo(parentCell: self,
            splitTime: NSDate().timeIntervalSince1970, timer: timer)
        
        splitCell.fillColor = SKColor.whiteColor()
        splitCell.eject()
        return splitCell
    }
    
    //function for copy cell
    private func copyCell() -> Cell {
        let newCell: Cell = self.copy() as! Cell
        newCell.controller = self.controller
        newCell.cellMaxSpeed = self.cellMaxSpeed
        newCell.speedX = self.speedX
        newCell.speedY = self.speedY
        newCell.physicsBody?.collisionBitMask = PhysicsCategory.Player
        return newCell
    }
    
    private func eject(){
        var direction: CGVector
        direction = CGVectorMake(speedX, speedY)
        let scale = self.scaleVectorWithLength(100, vector: direction)
        let speedVector = CGVectorMake(-direction.dx * scale, direction.dy * scale)
        let action = SKAction.moveBy(speedVector, duration: 1)
        //let group = SKAction.sequence(actions)
        self.runAction(action)

    }
    
    ///Combine cells
    func mergeToParent(){
        //If split info is empty
        if(splitInfo == nil){
            return
        }
        
        //Check the timer pass
        if(NSDate().timeIntervalSince1970 - (splitInfo?.splitTime)! < secToMerge){
            return
        }
        
        let parentCell = self.splitInfo?.parentCell
        
        //Check the two cells are near
        let xDiff = parentCell!.position.x - self.position.x
        let yDiff = self.position.y - parentCell!.position.y
        let distance = sqrt(xDiff * xDiff + yDiff * yDiff)
        
        if(distance/(self.xScale/2 + ((splitInfo?.parentCell.xScale)!/2)) > 58){
            return
        }
        
        //Stop timer
        self.splitInfo?.timer.invalidate()
        
        //Reset the radius of the parent cell
        parentCell!.xScale += self.xScale
        parentCell!.yScale += self.yScale
        
        //Change the position of the cell
        parentCell!.position = CGPointMake((self.position.x + parentCell!.position.x)/2, (self.position.y + parentCell!.position.y)/2)
        parentCell!.speedX /= 2
        parentCell!.speedY /= 2
        
        //Delete the child cell
        self.removeFromParent()
        isMerged = true
        
        //Remove cells in user
        //controller?.removeCellFromList(self)
    }
    
    func reduceSpeed(){
        
    }
    
    func childModifySpeed(){
        if(self.splitInfo == nil){
            return
        }
        
        //Check the timer pass
        if(NSDate().timeIntervalSince1970 - (splitInfo?.splitTime)! < 1.5){
            return
        }

        let diffX = (splitInfo?.parentCell.position.x)! - self.position.x
        let diffY = (splitInfo?.parentCell.position.y)! - self.position.y
        //let dis = sqrt(diffX * diff)
        
        self.speedX = (splitInfo?.parentCell.speedX)! - (diffX/100)
        self.speedY = (splitInfo?.parentCell.speedY)! + (diffY/100)
    }
    
}