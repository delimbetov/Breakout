//
//  BreakoutBehaviour.swift
//  Breakout
//
//  Created by Кирилл Делимбетов on 30.01.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

import UIKit

class BreakoutBehaviour: UIDynamicBehavior, UICollisionBehaviorDelegate {
    
    var ball: BallView? = nil {
        didSet {
            if ball != nil {
                ballBehaviour.addItem(ball!)
                collision.addItem(ball!)
                pushBehaviour.addItem(ball!)
            }
        }
        willSet {
            if ball != nil {
                ballBehaviour.removeItem(ball!)
                collision.removeItem(ball!)
                pushBehaviour.removeItem(ball!)
                ball!.removeFromSuperview()
            }
        }
    }
    
    var instanteneousPush = false
    var reportBallHitBottom: (() -> Void)?
    
    func add(item: UIDynamicItem) {
        collision.addItem(item)
        itemBehaviour.addItem(item)
    }
    
    func instantaneousPush(from location: CGPoint) {
        guard let ball = ball else { print("integrity err push"); return }
        
        if instanteneousPush {
            let angle = atan2(location.x - ball.frame.origin.x, location.y - ball.frame.origin.y)
            
            print(location, ball.frame.origin, angle)
            pushBehaviour.active = false
            pushBehaviour.angle = -angle - CGFloat(M_PI) / 2
            pushBehaviour.active = true
        } else {
            print("instanteneousPush turned off")
        }
    }
    
    func remove(item: UIDynamicItem) {
        collision.removeItem(item)
        itemBehaviour.removeItem(item)
    }
    
    func reset() {
        ball = nil
        savedLinearVelocity = nil
        
        pushBehaviour.active = false
        pushBehaviour.angle = BreakoutBehaviour.downAngle
        pushBehaviour.active = true
        
        for item in collision.items {
            collision.removeItem(item)
        }
        
        for item in itemBehaviour.items {
            itemBehaviour.removeItem(item)
        }
    }
    
    func resetBoundaryBottom(frame: CGRect) {
        let bottomLeft = CGPoint(x: frame.origin.x, y: frame.origin.y + frame.height)
        let bottomRight = CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y + frame.height)
        
        collision.addBoundary(withIdentifier: BreakoutBehaviour.boundaryBottom as NSCopying, from: bottomLeft, to: bottomRight)
    }
    
    func restoreLinearVelocity() {
        if let ball = ball, let savedlv = savedLinearVelocity {
            let curr = ballBehaviour.linearVelocity(for: ball)
            
            //reset to null
            ballBehaviour.addLinearVelocity(CGPoint(x: -curr.x, y: -curr.y), for: ball)
            //set to saved
            ballBehaviour.addLinearVelocity(savedlv, for: ball)
        }
    }
    
    func saveLinearVelocity() {
        if let ball = ball {
            savedLinearVelocity = ballBehaviour.linearVelocity(for: ball)
        }
    }
    
    override init() {
        super.init()
        
        collision.collisionDelegate = self
        addChildBehavior(ballBehaviour)
        addChildBehavior(collision)
        addChildBehavior(itemBehaviour)
        addChildBehavior(pushBehaviour)
    }
    
    //MARK: UICollisionBehaviourDelegate
    func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item1: UIDynamicItem, with item2: UIDynamicItem) {
        guard let ball = self.ball, ball === item1 else {
            print("integrity collision err 1")
            return
        }
        
        if let brick = item2 as? BrickView {
            brick.hitsTillCollapse -= 1
        }
        
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
        guard let ball = self.ball, ball === item else {
            print("integrity collision err 2")
            return
        }
        
        if let identifier = identifier, identifier as! String == BreakoutBehaviour.boundaryBottom {
            reportBallHitBottom!()
        }
    }
    
    //MARK: private
    private static let boundaryBottom = "Bottom boundary"
    private static let downAngle = CGFloat(M_PI) / 2.0
    private var savedLinearVelocity: CGPoint? = nil
    
    //MARK:behaviours
    private let ballBehaviour: UIDynamicItemBehavior = {
        let behaviour = UIDynamicItemBehavior()
        
        behaviour.allowsRotation = false
        behaviour.elasticity = 1
        behaviour.resistance = 0
        
        return behaviour
    }()
    
    private let collision: UICollisionBehavior = {
        let collision = UICollisionBehavior()
        
        collision.translatesReferenceBoundsIntoBoundary = true
        
        return collision
    }()
    
    private let itemBehaviour: UIDynamicItemBehavior = {
        let behaviour = UIDynamicItemBehavior()
        
        behaviour.isAnchored = true
        
        return behaviour
    }()
    
    private class func createPushBehaviour(to angle: CGFloat) -> UIPushBehavior {
        let push = UIPushBehavior(items: [], mode: .instantaneous)
        
        push.angle = angle
        push.magnitude = 0.2
        push.active = true
        
        return push
    }
    
    private var pushBehaviour: UIPushBehavior = BreakoutBehaviour.createPushBehaviour(to: BreakoutBehaviour.downAngle)
    
}
