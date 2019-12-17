//
//  StationTabBarViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/12/9.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class StationTabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = UIColor(red: 1/255, green: 194/255, blue: 176/255, alpha: 1)
        
    }

    @IBAction func tapToAddGoods(_ sender: UIBarButtonItem) {
        if let sendGoodsVC = storyboard?.instantiateViewController(withIdentifier: "sendGoodsVC") as? SendViewController {
            sendGoodsVC.preparedVC = self.viewControllers![0] as? PreparedStationViewController
            self.navigationController?.pushViewController(sendGoodsVC, animated: true)
        }
    }
    
}
