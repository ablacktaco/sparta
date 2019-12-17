//
//  SendViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/12/8.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class SendViewController: UIViewController {

    var belongings = [Belongings]()
    var index: Int?
    var destination: String?
    var preparedVC: PreparedStationViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        weightText.addTarget(self, action: #selector(checkContent), for: .editingChanged)
        freightText.addTarget(self, action: #selector(checkContent), for: .editingChanged)
        
        weightText.keyboardType = .decimalPad
        freightText.keyboardType = .numberPad
        
        belongingsTable.tableFooterView = UIView()
        
        getBelongings { (belongings) in
            self.belongings = belongings
            DispatchQueue.main.async {
                self.belongingsTable.reloadData()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBOutlet var countrySeg: UISegmentedControl!
    @IBOutlet var weightText: UITextField!
    @IBOutlet var freightText: UITextField!
    @IBOutlet var loadingData: UIActivityIndicatorView!
    @IBOutlet var sendingButton: UIButton! {
        didSet { setViewBorder(view: sendingButton, configSetting: .mainButton) }
    }
    @IBOutlet var belongingsTable: UITableView!
    
    @IBAction func tapToSend(_ sender: UIButton) {
        postGoods()
    }
}

extension SendViewController {
    
    @objc func checkContent() {
        if getEffectiveText(weightText) == "" || getEffectiveText(freightText) == "" || index == nil {
            sendingButton.alpha = 0.2
            sendingButton.isEnabled = false
        } else {
            sendingButton.alpha = 1
            sendingButton.isEnabled = true
        }
    }
    
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
    
    func postGoods() {
        
        switch countrySeg.selectedSegmentIndex {
        case 0: destination = "雅典"
        case 1: destination = "阿卡迪亞"
        case 2: destination = "菲基斯"
        default: break
        }
        
        let sendingGoods = SendGoods(des_station_name: destination!, weight: Double(getEffectiveText(weightText))!, price: Int(getEffectiveText(freightText))!)
        guard let uploadData = try? JSONEncoder().encode(sendingGoods) else { return }

        let url = URL(string: "http://34.80.65.255/api/goods/\(index!)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(UserData.shared.token, forHTTPHeaderField: "remember_token")

        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
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
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                            DispatchQueue.main.async {
                                self.loadingData.isHidden = false
                                self.preparedVC?.getStationGoods { (stationGoods) in
                                    self.preparedVC?.preparedStationGoods = stationGoods.result.filter { ($0.status == "準備中") }
                                    DispatchQueue.main.async {
                                        self.preparedVC?.preparedStationGoodsTable.reloadData()
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                }
                            }
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    func getEffectiveText(_ textField: UITextField) -> String {
        return textField.text!.trimmingCharacters(in: .whitespaces)
    }
    
    @objc func keyboardShow(_ notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let intersection = keyboardSize.intersection(self.view.frame)
        self.view.frame.origin.y -= intersection.height - 50
    }
    
    @objc func keyboardHide(_ notification: Notification) {
        self.view.frame.origin.y = 0
    }
    
}

extension SendViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return belongings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "sendCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SendTableViewCell
        
        cell.setbelongingsData(belongings, indexPath: indexPath)
        cell.selectionStyle = .gray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = belongings[indexPath.row].id
        if getEffectiveText(weightText) == "" || getEffectiveText(freightText) == "" || index == nil {
            sendingButton.alpha = 0.2
            sendingButton.isEnabled = false
        } else {
            sendingButton.alpha = 1
            sendingButton.isEnabled = true
        }
    }
    
}

extension SendViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
