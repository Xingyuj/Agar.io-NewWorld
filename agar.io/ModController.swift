//
//  FoodController.swift
//  agar.io
//
//  Created by F on 12/10/2015.
//  Copyright © 2015 UniMelb. All rights reserved.
//

import Foundation
import SpriteKit
import MultipeerConnectivity

class ModController {
    let initFoodNum = 50
    let initViruseNum = 5
    var mapWidth: UInt32?
    var mapHeight: UInt32?
    var foodsList: [Food]
    var viruseList: [Viruse]
    var cellDic: [MCPeerID:SKShapeNode]
    
    init(){
        foodsList = []
        viruseList = []
        cellDic = [MCPeerID:SKShapeNode]()
    }
    
    func createFoodsForInit()->[Food]{
        var appendList : [Food] = []
        for _ in 0...initFoodNum{
            appendList.append(createFood())
        }
        return appendList
    }
    
    func createViruseForInit()->[Viruse]{
        var appendList : [Viruse] = []
        for _ in 0...initViruseNum{
            appendList.append(createViruse())
        }
        return appendList
    }
    
    func getRandomPosition() ->CGPoint{
        return CGPoint(
            x: Int(arc4random_uniform(mapWidth!)),
            y: Int(arc4random_uniform(mapHeight!))
        )
    }
    
    func setupFrameSize(width: UInt32, height: UInt32 ){
        self.mapWidth = width
        self.mapHeight = height
    }
    
    func createFood()->Food{
        let newFood = Food(position: getRandomPosition())
        newFood.lineWidth = 3
        newFood.strokeColor = SKColor.whiteColor()
        return newFood
    }
    
    func createViruse() ->Viruse{
        let newViruse = Viruse(radius: 40, position: getRandomPosition())
        return newViruse
    }
}