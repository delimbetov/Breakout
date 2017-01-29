//
//  GameSceneView.swift
//  Breakout
//
//  Created by Кирилл Делимбетов on 29.01.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

import UIKit

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
                //add behaviours
            } else {
                //remove behaviours
            }
        }
    }
    
    var reportScore: ((Int) -> Void)?
    
    func reset() {
        animate = false
        
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
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
    
    private func addBrick(withFrame frame: CGRect) {
        let brick = UIView(frame: frame)
        
        brick.backgroundColor = UIColor.red
        addSubview(brick)
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
        let paddle = UIView()
        var origin = CGPoint()
        
        origin.x = (bounds.size.width - CGFloat(paddleWidth)) / 2
        origin.y = bounds.size.height - Defaults.paddleHeight - Defaults.paddleSpacing
        
        paddle.frame = CGRect(origin: origin, size: CGSize(width: CGFloat(paddleWidth), height: Defaults.paddleHeight))
        paddle.backgroundColor = UIColor.black
        addSubview(paddle)
    }
    
}
