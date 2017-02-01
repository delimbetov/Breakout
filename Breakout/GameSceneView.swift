//
//  GameSceneView.swift
//  Breakout
//
//  Created by Кирилл Делимбетов on 29.01.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

import UIKit

class Paddle: UIView {
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
}

class GameSceneView: UIView {
    
    //MARK: public
    var amountOfLines = 5
    var bricksPerLine = 8
    var paddleWidth = 50
    var speedOfBall = 1
    
    var animate = false {
        didSet {
            if animate == oldValue {
                return
            }
            
            if animate {
                animator.addBehavior(behaviour)
                behaviour.restoreLinearVelocity()
            } else {
                behaviour.saveLinearVelocity()
                animator.removeBehavior(behaviour)
            }
        }
    }
    
    var reportScore: ((Int) -> Void)?
    
    var xorigin = CGFloat()
    func pan(_ gesture: UIPanGestureRecognizer) {
        if true {
            switch gesture.state {
            case .began:
                xorigin = gesture.location(in: paddle).x
            case .changed:
                //animate hack because you can't move view that is animated
                animate = false
                paddle.frame.origin.x += gesture.location(in: paddle).x - xorigin
                animate = true
            default:
                break
            }
        }
    }
    
    func reset() {
        animate = false
        
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        behaviour.reset()
        
        load()
        reportScore?(0)
    }
    
    //MARK: private
    private struct Defaults {
        static let ballRadius: CGFloat = 8
        static let brickHeight: CGFloat = 15
        static let bricksSpacing: CGFloat = 15
        static let linesSpacing: CGFloat = 10
        static let paddleHeight: CGFloat = 10
        static let paddleSpacing: CGFloat = 15
    }
    
    private lazy var animator: UIDynamicAnimator = {
        return UIDynamicAnimator(referenceView: self)
    }()
    private let behaviour = BreakoutBehaviour()
    private var paddle: Paddle!
    
    private func addBrick(withFrame frame: CGRect) {
        let brick = BrickView(frame: frame)
        
        brick.collapse = { [unowned self](brick: BrickView) in
            self.behaviour.remove(item: brick)
        }
        brick.hitsTillCollapse = arc4random() % 2 + UInt32(1) //1...2
        addSubview(brick)
        behaviour.add(item: brick)
    }
    
    private func load() {
        loadBall()
        loadBricks()
        loadPaddle()
    }
    
    private func loadBall() {
        let ball = BallView()
        var origin = CGPoint()

        origin.x = bounds.size.width / 2 - Defaults.ballRadius
        origin.y = bounds.size.height / 2 - Defaults.ballRadius
        ball.frame = CGRect(origin: origin, size: CGSize(width: Defaults.ballRadius * 2, height: Defaults.ballRadius * 2))
        ball.backgroundColor = UIColor.clear
        addSubview(ball)
        behaviour.ball = ball
    }
    
    private func loadBricks() {
        let brickWidth = (bounds.size.width - Defaults.bricksSpacing * (CGFloat(bricksPerLine) + 1)) / CGFloat(bricksPerLine)
        
        for lineNumber in 0..<amountOfLines {
            let y = Defaults.linesSpacing + CGFloat(lineNumber) * (Defaults.brickHeight + Defaults.linesSpacing)
            
            if y >= (bounds.size.height / 2 - Defaults.ballRadius - Defaults.brickHeight - 1) {
                print("too much lines; breakin")
                break
            }
            
            for brickNumber in 0..<bricksPerLine {
                let x = Defaults.bricksSpacing + CGFloat(brickNumber) * (brickWidth + Defaults.bricksSpacing)
                
                addBrick(withFrame: CGRect(x: x, y: y, width: brickWidth, height: Defaults.brickHeight))
            }
        }
    }
    
    private func loadPaddle() {
        var origin = CGPoint()
        
        paddle = Paddle()
        origin.x = (bounds.size.width - CGFloat(paddleWidth)) / 2 + 10
        origin.y = bounds.size.height - Defaults.paddleHeight - Defaults.paddleSpacing
        
        paddle.frame = CGRect(origin: origin, size: CGSize(width: CGFloat(paddleWidth), height: Defaults.paddleHeight))
        paddle.backgroundColor = UIColor.black
        addSubview(paddle)
        behaviour.add(item: paddle)
    }
    
}
