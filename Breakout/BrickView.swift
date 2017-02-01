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
    let fadingDuration = 2.0
    
    var hitsTillCollapse: UInt32 = 0 {
        didSet {
            switch hitsTillCollapse {
            case 0:
                collapse(self) //if nil crash coz game breaking bug
                UIView.animate(withDuration: fadingDuration, animations: { self.alpha = 0.0 }, completion: { finished in self.removeFromSuperview() })
            case 1:
                backgroundColor = UIColor.red
            case 2:
                backgroundColor = UIColor.magenta
            default:
                backgroundColor = UIColor.green
            }
            
            setNeedsDisplay()
        }
    }

}
