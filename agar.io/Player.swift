//
//  Player.swift
//  agar.io
//
//  Created by F on 12/10/2015.
//  Copyright © 2015 UniMelb. All rights reserved.
//
import Foundation
import SpriteKit

class Player{
    // skins
    let skins = ["china","usa"]
    // color
    let color = [SKColor.blackColor(),SKColor.blueColor(),SKColor.redColor(),SKColor.yellowColor()]
    var accelerometer : Bool
    var playerName : String?
    var centralCell : Cell?
    var cellsList : [Cell]
    var foodEaten : Int
    var highestMass : CGFloat
    var startTime : Double
    var cellsEaten : Int
    var lastTouch: CGPoint?
    //leaderboard time
    
    init(playerName : String){
        self.accelerometer = false
        self.playerName = playerName
        self.cellsList = [Cell]()
        self.foodEaten = 0
        self.highestMass = 0
        self.cellsEaten = 0
        self.startTime = NSDate().timeIntervalSince1970
    }
    
    func createInitCell(location: CGPoint)->Cell{
        var cell = Cell(controller: self, location: location)
        cell.strokeColor = SKColor.blackColor()
        cell.lineWidth = 1
        cell.label.text = self.playerName
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

        if(playerName != nil) {
            if(skins.contains(playerName!)) {
                cell.fillColor = SKColor.whiteColor()
                cell.fillTexture = SKTexture(imageNamed: "\(self.playerName!).png")
            } else {
                cell.fillColor = color[Int(arc4random_uniform(UInt32(color.count)))]
            }
        } else {
            cell.fillColor = color[Int(arc4random_uniform(UInt32(color.count)))]
        }
        
        self.centralCell = cell
        cellsList.append(cell)
        return centralCell!
    }
    
    //return the central cell in the screen
    func getCentralCell()->Cell{
        return centralCell!
    }
    
    //return cells list
    func getCellsList()->[Cell]{
        return cellsList
    }
    
    //User do action to split cells
    //Each cell exist could split to 2 same size cells
    func splitCells()->[Cell]{
        var splitCells:[Cell] = [Cell]()
        if(cellsList.count >= 2){
            return splitCells
        }
        for cell in cellsList {
            let splitCell = cell.split()
            cellsList.append(splitCell)
            splitCells.append(splitCell)
        }
        print(splitCells.count)
        return splitCells
    }
    
    func checkMerge(){
        //var combinedList: [Cell] = []
        if(cellsList.count > 1){
            for index in 0...1{
                if(cellsList[index].isMerged == true){
                    cellsList.removeAtIndex(index)
                }else{
                    cellsList[index].mergeToParent()
                }
            }
        }
        
    }
    
    
}