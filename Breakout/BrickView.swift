//
//  BrickView.swift
//  Breakout
//
//  Created by Кирилл Делимбетов on 30.01.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

import UIKit

class BrickView: UIView {

    var collapse: ((BrickView) -> Void)!
    let fadingDuration = 1.0
    
    var hitsTillCollapse: UInt32 = 0 {
        didSet {
            brickIsHitReporter?(hitsTillCollapse)
            paintBackground()
        }
    }
    
    init(frame: CGRect, hitsToCollapse: UInt32, brickIsHit: @escaping (UInt32) -> ()) {
        super.init(frame: frame)
        hitsTillCollapse = hitsToCollapse
        paintBackground()
        brickIsHitReporter = brickIsHit
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var brickIsHitReporter: ((UInt32) -> ())?
    private func paintBackground() {
        switch hitsTillCollapse {
        case 0:
            collapse(self) //if nil crash coz game breaking bug
            UIView.animate(withDuration: fadingDuration, animations: { self.alpha = 0.0 }, completion: { finished in self.removeFromSuperview() })
        case 1:
            backgroundColor = UIColor.green
        case 2:
            backgroundColor = UIColor.yellow
        default:
            print("hitsTillCollapse err")
        }
        
        setNeedsDisplay()
    }
}
