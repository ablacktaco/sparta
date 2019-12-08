//
//  UserViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/25.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {
    
    var totalCase: Int?
    var rate: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = UserData.shared.name
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        navigationItem.backBarButtonItem?.tintColor = UIColor(red: 1/255, green: 194/255, blue: 176/255, alpha: 1)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserMoney { (userInfo) in
            DispatchQueue.main.async {
                UserData.shared.id = userInfo.id
                self.nameLabel.text = UserData.shared.name
                if UserData.shared.role == 1 {
                    self.roleLabel.text = "Role: Mercenary"
                } else {
                    self.roleLabel.text = "Role: Mortal"
                }
                self.moneyLabel.text = "Property: $\(userInfo.money)"
                self.totalCase = userInfo.experience
                self.rate = userInfo.achieveRate
            }
        }
    }
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var roleLabel: UILabel!
    @IBOutlet var moneyLabel: UILabel!
    @IBOutlet var userButtons: [UIButton]! {
        didSet {
            for button in userButtons {
                setViewBorder(view: button, configSetting: .mainButton)
            }
        }
    }
    
    @IBAction func tapToEarnMoney(_ sender: UIButton) {
        if let gameRuleVC = self.storyboard?.instantiateViewController(withIdentifier: "gameRuleVC") as? GameRuleViewController {
            gameRuleVC.userVC = self
            self.present(gameRuleVC, animated: true, completion: nil)
        }
    }
    @IBAction func tapToCheckUserData(_ sender: UIButton) {
        if let userDataVC = storyboard?.instantiateViewController(withIdentifier: "userDataVC") as? UserDataViewController {
            userDataVC.userName = UserData.shared.name
            userDataVC.userMoney = moneyLabel.text
            userDataVC.userRole = roleLabel.text
            userDataVC.allCase = totalCase
            userDataVC.acRate = rate
            self.navigationController?.pushViewController(userDataVC, animated: true)
        }
    }
    @IBAction func tapToSignOut(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Sign out", message: "Are you sure to sign out?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            let alertController = UIAlertController(title: "Appreciate to see you next time.", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                UserData.shared.id = nil
                UserData.shared.name = nil
                UserData.shared.role = nil
                UserData.shared.token = nil
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alertController, animated: true, completion: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension UserViewController {
    
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
