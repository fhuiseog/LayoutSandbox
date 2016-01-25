//
//  RenderView.swift
//  LayoutSandbox
//
//  Created by John Cromie on 20/01/2016.
//  Copyright © 2016 RGB. All rights reserved.
//

import UIKit

class RenderView: UIView {
    
    var frames: [CGRect] = [CGRect]()
    
    override func drawRect(rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 0.5)
        CGContextSetStrokeColorWithColor(context,
            UIColor.blueColor().CGColor)
        
        for r in self.frames {
            
            CGContextAddRect(context, r)
        }

        CGContextStrokePath(context)
    }

}
    