//
//  BallView.swift
//  Breakout
//
//  Created by Кирилл Делимбетов on 29.01.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

import UIKit

class BallView: UIView {
    
    var fillingColor = UIColor.blue
    var lineWidth = 2
    var outlineColor = UIColor.black
    
    override func draw(_ rect: CGRect) {
        let origin = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        let path = UIBezierPath(arcCenter: origin, radius: (bounds.size.height - CGFloat(lineWidth)) / 2, startAngle: 0, endAngle: CGFloat(M_PI) * 2, clockwise: true)
        
        path.lineWidth = CGFloat(lineWidth)
        outlineColor.setStroke()
        fillingColor.setFill()
        path.stroke()
        path.fill()
    }

}
