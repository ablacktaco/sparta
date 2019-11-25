//
//  UserViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/25.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserMoney { (userMoney) in
            DispatchQueue.main.async {
                self.nameLabel.text = UserData.shared.name
                if UserData.shared.role == 1 {
                    self.roleLabel.text = "Role: Mercenary"
                } else {
                    self.roleLabel.text = "Role: Mortal"
                }
                self.moneyLabel.text = "Property: $\(userMoney.money)"
                self.costLabel.text = "Reward: $\(userMoney.cost)"
            }
        }
        
        navigationItem.title = UserData.shared.name
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        navigationItem.backBarButtonItem?.tintColor = UIColor(red: 1/255, green: 194/255, blue: 176/255, alpha: 1)
        
    }
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var roleLabel: UILabel!
    @IBOutlet var moneyLabel: UILabel!
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var userButtons: [UIButton]! {
        didSet {
            for button in userButtons {
                setViewBorder(view: button, configSetting: .mainButton)
            }
        }
    }
    @IBAction func tapToSignOut(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Sign out", message: "Are you sure to sign out?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            let alertController = UIAlertController(title: "Appreciate to see you next time.", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
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
    
    func getUserMoney(closure: @escaping (UserMoney) -> Void) {
                       
        let url = URL(string: "http://35.221.252.120/api/profile")!
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
                    if let userMoney = try? JSONDecoder().decode(UserMoney.self, from: data) {
                        closure(userMoney)
                    }
                }
            }
        }
        task.resume()
    }
    
}
