//
//  Viruse.swift
//  agar.io
//
//  Created by F on 12/10/2015.
//  Copyright © 2015 UniMelb. All rights reserved.
//

import Foundation
import SpriteKit

class Viruse: Disk {
    //New food
    override init(radius: CGFloat, position : CGPoint) {
        super.init(radius: radius, position : position)
        self.strokeColor = SKColor.greenColor()
        self.fillColor = SKColor.greenColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}