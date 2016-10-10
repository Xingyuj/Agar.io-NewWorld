//
//  Food.swift
//  agar.io
//
//  Created by F on 12/10/2015.
//  Copyright © 2015 UniMelb. All rights reserved.
//

import Foundation
import SpriteKit

class Food: Disk {
    let foodRadius : CGFloat = 10
    
    //New food
    init(position : CGPoint) {
        //let randomRadius = CGFloat(arc4random_uniform(maxRadius - minRadius))
        super.init(radius: self.foodRadius, position: position)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}