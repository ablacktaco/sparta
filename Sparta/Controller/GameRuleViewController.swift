//
//  GameRuleViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/12/8.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class GameRuleViewController: UIViewController {

    var userVC: UserViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet var enterGameButton: UIButton! {
        didSet { setViewBorder(view: enterGameButton, configSetting: .mainButton) }
    }
    @IBAction func tapToEnterGame(_ sender: UIButton) {
        if let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "gameVC") as? GameViewController {
            gameVC.userVC = userVC
            self.present(gameVC, animated: true, completion: nil)
        }
    }

}
