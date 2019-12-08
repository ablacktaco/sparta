//
//  UserDataViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/12/6.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class UserDataViewController: UIViewController {

    var belongings = [Belongings]()
    
    var userName: String?
    var userMoney: String?
    var userRole: String?
    var allCase: Int?
    var acRate: Int?
    
    var keyAlert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = userName
        
        belongingsTable.tableFooterView = UIView()
        
        getBelongings { (belongings) in
            self.belongings = belongings
            DispatchQueue.main.async {
                self.belongingsTable.reloadData()
            }
        }
        
        if userRole == "Role: Mortal" {
            totalCase.isHidden = true
            rate.isHidden = true
        }
    }

    @IBOutlet var forgetKeyButton: UIButton! {
        didSet { setViewBorder(view: forgetKeyButton, configSetting: .chooseButton) }
    }
    @IBOutlet var name: UILabel! {
        didSet { name.text = userName }
    }
    @IBOutlet var property: UILabel! {
        didSet { property.text = userMoney }
    }
    @IBOutlet var role: UILabel! {
        didSet { role.text = userRole }
    }
    @IBOutlet var totalCase: UILabel! {
        didSet { totalCase.text = "Finished case: \(allCase!)" }
    }
    @IBOutlet var rate: UILabel! {
        didSet {
            if acRate == 0 {
                rate.text = "Achieve rate: 0 %"
            } else {
                rate.text = "Achieve rate: \(acRate! / allCase! * 100) %"
            }
        }
    }
    @IBOutlet var belongingsTable: UITableView!
    
    @IBAction func tapToGetKey(_ sender: UIButton) {
        keyAlert = UIAlertController(title: "Forget key", message: nil, preferredStyle: .alert)
        keyAlert!.addTextField { (textField) in
            textField.placeholder = "Enter your bank's account"
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        }
        keyAlert!.addTextField { (textField) in
            textField.placeholder = "Enter your bank's password"
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        }
        keyAlert!.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.getBankKey(userID: self.getEffectiveText((self.keyAlert?.textFields![0])!), password: self.getEffectiveText((self.keyAlert?.textFields![1])!))
        }))
        keyAlert?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        keyAlert?.actions[0].isEnabled = false
        self.present(keyAlert!, animated: true, completion: nil)
    }
    
}

extension UserDataViewController {
    
    func getBelongings(closure: @escaping ([Belongings]) -> Void) {
        
        let url = URL(string: "http://34.80.65.255/api/bought")!
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
                    if let belongings = try? JSONDecoder().decode([Belongings].self, from: data) {
                        closure(belongings)
                    }
                }
            }
        }
        task.resume()
    }
    
    func getBankKey(userID: String, password: String) {
        let bankUserData = BankUserData(userID: userID, password: password)
        guard let uploadData = try? JSONEncoder().encode(bankUserData) else { return }

        let url = URL(string: "https://bboa14171205.nctu.me/api/user/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
            if let error = error {
                print ("error: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("status code: \(response.statusCode)")
                if response.statusCode != 200 {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Error", message: "Wrong account or password", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    return
                }
                if let mimeType = response.mimeType,
                    mimeType == "application/json",
                    let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    print("got data: \(dataString)")
                    let key = self.decodeBankData(data)
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Your bank's key is \(key)", message: nil, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    func decodeBankData(_ data: Data) -> String {
        if let decodedData = try? JSONDecoder().decode(DecodeBank.self, from: data) {
            return decodedData.key
        }
        return ""
    }
    
    func getEffectiveText(_ textField: UITextField) -> String {
        return textField.text!.trimmingCharacters(in: .whitespaces)
    }
    
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        keyAlert!.actions[0].isEnabled = getEffectiveText((keyAlert?.textFields![0])!).count > 0 && getEffectiveText((keyAlert?.textFields![1])!).count >= 6
    }
}

extension UserDataViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return belongings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "belongingsCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! BelongingsTableViewCell
        
        cell.setbelongingsData(belongings, indexPath: indexPath)
        cell.selectionStyle = .none
        
        return cell
    }
    
}
