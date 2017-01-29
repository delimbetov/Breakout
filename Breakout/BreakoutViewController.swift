//
//  FirstViewController.swift
//  Breakout
//
//  Created by Кирилл Делимбетов on 29.01.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController {

    //MARK: public
    
    //MARK: outlets
    @IBOutlet weak var gameView: GameSceneView!
    
    //MARK: actions
    @IBAction func resetTouched(_ sender: UIBarButtonItem) {
        gameView.reset()
    }
    
    @objc private func pauseTouched(_ sender: UIBarButtonItem) {
        gameView.animate = false
        navigationItem.rightBarButtonItem = nil
        addPlayButton()
    }
    
    @objc private func playTouched(_ sender: UIBarButtonItem) {
        gameView.animate = true
        navigationItem.rightBarButtonItem = nil
        addPauseButton()
        
    }
    
    //MARK: private
    private var animateStateBeforeDisappear = false
    private var score: Int {
        get {
            if let title = navigationItem.title, let number = Int(title) {
                return number
            } else {
                print("couldnt get score")
                return -1
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
    
    //MARK: UIViewController 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animateStateBeforeDisappear = gameView.animate
        addPlayButton()
        gameView.reportScore = { [unowned self](score: Int) in  self.score = score }
        gameView.reset()
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

