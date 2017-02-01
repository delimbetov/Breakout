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
            }
        }
    }
    
    func add(item: UIDynamicItem) {
        collision.addItem(item)
        itemBehaviour.addItem(item)
    }
    
    func remove(item: UIDynamicItem) {
        collision.removeItem(item)
        itemBehaviour.removeItem(item)
    }
    
    func reset() {
        ball = nil
        savedLinearVelocity = nil
        
        removeChildBehavior(pushBehaviour)
        pushBehaviour = BreakoutBehaviour.createPushBehaviour()
        addChildBehavior(pushBehaviour)
        
        for item in collision.items {
            collision.removeItem(item)
        }
        
        for item in itemBehaviour.items {
            itemBehaviour.removeItem(item)
        }
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
        print(ballBehaviour.linearVelocity(for: ball))
    }
    
    //MARK: private
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
    
    private class func createPushBehaviour() -> UIPushBehavior {
        let push = UIPushBehavior(items: [], mode: .instantaneous)
        
        push.angle = CGFloat(M_PI / 2.0)
        push.magnitude = 0.1
        push.active = true
        
        return push
    }
    
    private var pushBehaviour: UIPushBehavior = BreakoutBehaviour.createPushBehaviour()
    
}
