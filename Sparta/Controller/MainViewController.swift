//
//  MainViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/25.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet var mainButtons: [UIButton]! {
        didSet {
            for button in mainButtons {
                setViewBorder(view: button, configSetting: .mainButton)
            }
        }
    }
    
}
