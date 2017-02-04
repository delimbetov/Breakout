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
    var amountOfLines = 2
    var bricksPerLine = 3
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
    
    var reportEndOfTheGame: ((Result) -> Void)?
    var reportScore: ((UInt32) -> Void)?
    
    func reset() {
        animate = false
        bricksLeft = 0
        score = 0
        
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        behaviour.reset()
        load()
    }
    
    //MARK: gesture handlers
    func pan(_ gesture: UIPanGestureRecognizer) {
        if animate {
            switch gesture.state {
            case .began:
                //if i change self to paddle it works. what the fuck
                panPrevLocationX = gesture.location(in: self).x
            case .changed:
                //animate hack because you can't move view that is animated
                animate = false
                paddle.frame.origin.x += gesture.location(in: self).x - panPrevLocationX
                panPrevLocationX = gesture.location(in: self).x
                animate = true
            default:
                break
            }
        }
    }
    
    func tap(_ gesture: UIPanGestureRecognizer) {
        if animate, gesture.state == .ended {
            behaviour.instantaneousPush(from: gesture.location(in: self))
        }
    }
    
    //MARK: private
    private struct Defaults {
        static let ballRadius: CGFloat = 8
        static let brickHeight: CGFloat = 15
        static let bricksSpacing: CGFloat = 15
        static let pointsCollapse: UInt32 = 15
        static let pointsHit: UInt32 = 10
        static let linesSpacing: CGFloat = 10
        static let paddleHeight: CGFloat = 10
        static let paddleSpacing: CGFloat = 15
    }
    
    private lazy var animator: UIDynamicAnimator = {
        return UIDynamicAnimator(referenceView: self)
    }()
    private lazy var behaviour: BreakoutBehaviour = {
        let behaviour = BreakoutBehaviour(frame: self.bounds)
        
        behaviour.reportBallHitBottom = {
            [unowned self]() in
            self.reportEndOfTheGame?(Result.lose)
        }
        
        return behaviour
    }()
    private var bricksLeft: UInt = 0 {
        didSet {
            //check for animate to exclude invoking from reset()
            if bricksLeft == 0 && animate {
                reportEndOfTheGame?(Result.win)
            }
        }
    }
    private var paddle: Paddle!
    private var panPrevLocationX = CGFloat()
    private var score: UInt32 = 0 {
        didSet {
            reportScore?(score)
        }
    }
    
    private func addBrick(withFrame frame: CGRect) {
        let brick = BrickView(frame: frame, hitsToCollapse: arc4random() % 2 + UInt32(1) /*1..2*/, brickIsHit: {
            [unowned self](hitsTillCollapse) in
            if hitsTillCollapse == 0 {
                self.score += Defaults.pointsCollapse
                self.bricksLeft -= 1
            } else {
                self.score += Defaults.pointsHit
            }
            })
        
        brick.collapse = { [unowned self](brick: BrickView) in
            self.behaviour.remove(item: brick)
        }
        addSubview(brick)
        bricksLeft += 1
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
        origin.x = (bounds.size.width - CGFloat(paddleWidth)) / 2
        origin.y = bounds.size.height - Defaults.paddleHeight - Defaults.paddleSpacing
        
        paddle.frame = CGRect(origin: origin, size: CGSize(width: CGFloat(paddleWidth), height: Defaults.paddleHeight))
        paddle.backgroundColor = UIColor.black
        addSubview(paddle)
        behaviour.add(item: paddle)
    }
    
}
