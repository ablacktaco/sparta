//
//  MewcenaryRuleViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/12/3.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class MercenaryRuleViewController: UIViewController {

    var registerVC: RegisterViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBOutlet var okButton: UIButton! {
        didSet { setViewBorder(view: okButton, configSetting: .mainButton) }
    }

    @IBAction func tapToEnterGame(_ sender: UIButton) {
        if let qualVC = storyboard?.instantiateViewController(withIdentifier: "qualVC") as? QualificationViewController {
            qualVC.regiVC = registerVC
            present(qualVC, animated: true, completion: nil)
        }
    }
    
}
