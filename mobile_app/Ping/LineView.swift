//
//  LineView.swift
//  Ping
//
//  Created by Noah Krim on 3/9/15.
//  Copyright (c) 2015 Ping. All rights reserved.
//

import Foundation
import UIKit

class LineView: UIView  {
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let cntx = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(cntx, UIColor.grayColor().CGColor)
        CGContextSetLineWidth(cntx, 1)
        //Below Image
        CGContextMoveToPoint(cntx, 15, 205)
        CGContextAddLineToPoint(cntx, self.bounds.width-15, 205)
        //Below Deal
        CGContextMoveToPoint(cntx, 15, 255)
        CGContextAddLineToPoint(cntx, self.bounds.width-15, 255)
        //Below Map
        CGContextMoveToPoint(cntx, 15, 575)
        CGContextAddLineToPoint(cntx, self.bounds.width-15, 575)
        //Draw
        CGContextStrokePath(cntx)
    }
}