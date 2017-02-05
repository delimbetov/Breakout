//
//  SecondViewController.swift
//  Breakout
//
//  Created by Кирилл Делимбетов on 29.01.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

import UIKit

protocol SettingsDelegate : class {
    func bricksPerLine(newValue: Int)
    func instanteneousPush(newValue: Bool)
    func paddleWidth(newValue: Int)
}

class SettingsViewController: UIViewController {

    weak var delegate: SettingsDelegate? {
        didSet {
            if delegate == nil {
                print("Set delegate first")
                return
            }
            
            if bricksPerLineStepper == nil || instanteneousPushSwitch == nil || paddleWidthSegmented == nil {
                print("View didnt load yet")
                return
            }
            
            bricksPerLineValueChanged(bricksPerLineStepper)
            instanteneousPushValueChanged(instanteneousPushSwitch)
            paddleWidthValueChanged(paddleWidthSegmented)
        }
    }
    
    //MARK: private
    private enum SegmentIndex : Int {
        case thin = 0
        case normal = 1
        case thick = 2
    }
    
    private let segmentIndexToValue: [SegmentIndex : Int] = [
        .thin : 30,
        .normal : 50,
        .thick : 80
    ]
    @IBOutlet private weak var bricksPerLine: UILabel!
    
    @IBOutlet weak var bricksPerLineStepper: UIStepper!
    @IBOutlet weak var instanteneousPushSwitch: UISwitch!
    @IBOutlet weak var paddleWidthSegmented: UISegmentedControl!
    
    @IBAction private func bricksPerLineValueChanged(_ sender: UIStepper) {
        let value = Int(sender.value)
        
        bricksPerLine.text = String(value)
        delegate?.bricksPerLine(newValue: value)
    }
    
    @IBAction private func instanteneousPushValueChanged(_ sender: UISwitch) {
        delegate?.instanteneousPush(newValue: sender.isOn)
    }
    
    @IBAction private func paddleWidthValueChanged(_ sender: UISegmentedControl) {
        delegate?.paddleWidth(newValue: segmentIndexToValue[SegmentIndex.init(rawValue: sender.selectedSegmentIndex)!]!)
    }
}

