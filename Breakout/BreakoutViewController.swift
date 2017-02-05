//
//  FirstViewController.swift
//  Breakout
//
//  Created by Кирилл Делимбетов on 29.01.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

import UIKit

enum Result {
    case win
    case lose
}

class BreakoutViewController: UIViewController, SettingsDelegate {

    //MARK: public
    
    //MARK: outlets
    @IBOutlet weak var gameView: GameSceneView!
    
    //MARK: actions
    @IBAction func resetTouched(_ sender: UIBarButtonItem) {
        gameView.reset()
        addPlayButton()
    }
    
    @objc private func pauseTouched(_ sender: UIBarButtonItem) {
        gameView.animate = false
        addPlayButton()
    }
    
    @objc private func playTouched(_ sender: UIBarButtonItem) {
        gameView.animate = true
        addPauseButton()
    }
    
    //MARK: private
    private struct Defaults {
        static let appearanceOfTextDuration = 1.5
        static let resetAfterEndOfTheGameIn = 3.0
    }
    private var animateStateBeforeDisappear = false
    private var score: UInt32 {
        get {
            if let title = navigationItem.title, let number = Int(title) {
                return UInt32(number)
            } else {
                print("couldnt get score")
                return UInt32.max
            }
        }
        set {
            navigationItem.title = String(newValue)
        }
    }
    
    private func addPauseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(pauseTouched(_:)))
    }
    
    private func addPlayButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(playTouched(_:)))
    }
    
    private func endGame(withText text: String) {
        let label = UILabel()
        
        UIView.animate(withDuration: Defaults.appearanceOfTextDuration, animations: {
            [unowned self] in
            
            self.gameView.addSubview(label)
            label.text = text
            label.font = UIFont.systemFont(ofSize: 40)
            label.sizeToFit()
            label.textAlignment = .center
            label.textColor = UIColor.black
            label.frame.origin.x = self.gameView.bounds.origin.x + self.gameView.bounds.width / 2 - label.frame.width / 2
            label.frame.origin.y = self.gameView.bounds.origin.y + self.gameView.bounds.height / 2 - label.frame.height / 2
        }, completion: {
            (finished: Bool) in
            if !finished {
                print("couldnt finish label animations")
                return
            }
            
            Timer.scheduledTimer(withTimeInterval: Defaults.resetAfterEndOfTheGameIn, repeats: false) {
                (timet: Timer) in
                UIView.animate(withDuration: Defaults.appearanceOfTextDuration, animations: {
                    label.alpha = 0.0
                    }, completion: {
                        [unowned self](finished: Bool) in
                        if !finished {
                            print("couldnt finish timer animation")
                            return
                        }
                        
                        label.removeFromSuperview()
                        self.gameView.reset()
                        self.addPlayButton()
                        })
                }
            })
    }
    
    //MARK: SettingsDelegate
    func bricksPerLine(newValue: Int) {
        gameView.bricksPerLine = newValue
    }
    
    func instanteneousPush(newValue: Bool) {
        gameView.instanteneousPush = newValue
    }
    
    func paddleWidth(newValue: Int) {
        gameView.paddleWidth = newValue
    }
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animateStateBeforeDisappear = gameView.animate
        addPlayButton()
        gameView.reportScore = {
            [unowned self](score: UInt32) in
            self.score = score
        }
        gameView.reportEndOfTheGame = {
            [unowned self](result: Result) in
            self.gameView.animate = false
            
            switch result {
            case .win:
                self.endGame(withText: "You won")
            case .lose:
                self.endGame(withText: "You lost")
            }
        }
        gameView.reset()
        gameView.addGestureRecognizer(UIPanGestureRecognizer(target: gameView, action: #selector(GameSceneView.pan(_:))))
        gameView.addGestureRecognizer(UITapGestureRecognizer(target: gameView, action: #selector(GameSceneView.tap(_:))))
        
        //app delegate
        (UIApplication.shared.delegate! as! AppDelegate).callOnStatusBarFrameChange = {
            [weak weakSelf = self] in
            weakSelf?.view.layoutSubviews()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gameView.animate = animateStateBeforeDisappear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animateStateBeforeDisappear = gameView.animate
        gameView.animate = false
    }
}

