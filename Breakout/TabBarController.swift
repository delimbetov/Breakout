//
//  TabBarController.swift
//  Breakout
//
//  Created by Кирилл Делимбетов on 05.02.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let nvc = viewControllers![0] as! UINavigationController
        let bvc = nvc.viewControllers[0] as! BreakoutViewController
        let svc = viewControllers![1] as! SettingsViewController
        
        svc.delegate = bvc
    }

}
