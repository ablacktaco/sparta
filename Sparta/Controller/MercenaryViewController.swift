//
//  MercenaryViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/12/5.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class MercenaryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Mercenary"
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = UIColor(red: 1/255, green: 194/255, blue: 176/255, alpha: 1)
        
        if UserData.shared.role == 0 {
            offerButton.isHidden = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserData.shared.role == 0 {
            offerButton.isHidden = true
        }
        
        getUserMoney { (userInfo) in
            DispatchQueue.main.async {
                self.moneyLabel.text = "Property: $\(userInfo.money)"
                self.costLabel.text = "Reward cost: $\(userInfo.cost)"
            }
        }
        
    }
    
    @IBOutlet var moneyLabel: UILabel!
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var offerButton: UIButton!
    @IBOutlet var mercenaryButtons: [UIButton]! {
        didSet {
            for button in mercenaryButtons {
                setViewBorder(view: button, configSetting: .mainButton)
            }
        }
    }
    @IBAction func tapToPostedReward(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Mortal", bundle: nil)
        if let mortalVC = storyboard.instantiateViewController(withIdentifier: "Mortal") as? PostViewController {
            self.navigationController?.pushViewController(mortalVC, animated: true)
        }
    }
    @IBAction func tapToManageOffer(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Mercenary", bundle: nil)
        if let missionVC = storyboard.instantiateViewController(withIdentifier: "missionVC") as? MissionViewController {
            self.navigationController?.pushViewController(missionVC, animated: true)
        }
    }
    
}

extension MercenaryViewController {
    
    func getUserMoney(closure: @escaping (UserInfo) -> Void) {
                       
        let url = URL(string: "http://34.80.65.255/api/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("keep-alive", forHTTPHeaderField: "connection")
        request.setValue(UserData.shared.token, forHTTPHeaderField: "remember_token")
                        
        let task = URLSession.shared.uploadTask(with: request, fromFile: url) { (data, response, error) in
            if let error = error {
                print ("error: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("status code: \(response.statusCode)")
                if let mimeType = response.mimeType,
                    mimeType == "application/json",
                    let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    print ("got data: \(dataString)")
                    if let userMoney = try? JSONDecoder().decode(UserInfo.self, from: data) {
                        closure(userMoney)
                    }
                }
            }
        }
        task.resume()
    }
    
}
