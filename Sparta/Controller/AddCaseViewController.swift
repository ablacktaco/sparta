//
//  AddCaseViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/27.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class AddCaseViewController: UIViewController {

    var rewardVC: RewardViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectImage.alpha = 0
        collectionLabel.isHidden = true
        
        navigationItem.title = "Add Mission"
        
        missionBudget.keyboardType = .numberPad
        
        addButton.alpha = 0.2
        addButton.isEnabled = false
        
        missionName.addTarget(self, action: #selector(checkContent), for: .editingChanged)
        missionBudget.addTarget(self, action: #selector(checkContent), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        keyboardHide()
    }
    
    @IBOutlet var killImage: UIImageView!
    @IBOutlet var collectImage: UIImageView!
    @IBOutlet var missionName: UITextField! {
        didSet { missionName.placeholder = "Enter mission name" }
    }
    @IBOutlet var collectionLabel: UILabel!
    @IBOutlet var missionBudget: UITextField!
    @IBOutlet var missionType: UISegmentedControl!
    @IBOutlet var missionDescription: UITextView!
    @IBOutlet var addButton: UIButton! {
        didSet { setViewBorder(view: addButton, configSetting: .mainButton) }
    }
    
    @IBAction func tapToChangeCategory(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            killImage.alpha = 1
            collectImage.alpha = 0
            collectionLabel.isHidden = true
            missionName.placeholder = "Enter mission name"
        } else {
            killImage.alpha = 0
            collectImage.alpha = 1
            collectionLabel.isHidden = false
            missionName.placeholder = "Enter collected object"
        }
    }
    @IBAction func tapToAddMission(_ sender: UIButton) {
        addMission()
    }
    
}

extension AddCaseViewController {
    
    @objc func checkContent() {
        if getEffectiveText(missionName) == "" || getEffectiveText(missionBudget) == "" {
            addButton.alpha = 0.2
            addButton.isEnabled = false
        } else {
            addButton.alpha = 1
            addButton.isEnabled = true
        }
    }
    
    func getEffectiveText(_ textField: UITextField) -> String {
        return textField.text!.trimmingCharacters(in: .whitespaces)
    }
    
    func addMission() {
        
        var missionData = AddMission(name: "", category: 0, budget: 0, descript: "")
        
        if missionType.selectedSegmentIndex == 0 {
            missionData = AddMission(name: missionName.text!, category: missionType.selectedSegmentIndex + 1, budget: Int( missionBudget.text!)!, descript: missionDescription.text)
        } else {
            missionData = AddMission(name: "蒐集\(missionName.text!)", category: missionType.selectedSegmentIndex + 1, budget: Int( missionBudget.text!)!, descript: missionDescription.text)
        }
        guard let uploadData = try? JSONEncoder().encode(missionData) else { return }
            
        let url = URL(string: "http://34.80.65.255/api/reward/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("keep-alive", forHTTPHeaderField: "connection")
        request.setValue(UserData.shared.token, forHTTPHeaderField: "remember_token")
                            
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
            if let error = error {
                print ("error: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("status code: \(response.statusCode)")
                if response.statusCode == 416 {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Your property can't afford the budget.", message: nil, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    return
                }
                if let mimeType = response.mimeType,
                    mimeType == "application/json",
                    let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    print ("got data: \(dataString)")
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                            self.rewardVC?.getRewardData(closure: { (rewardData) in
                                self.rewardVC?.rewardList = rewardData.reward
                                self.rewardVC?.undoRewardList = (self.rewardVC?.rewardList.filter { ($0.done == nil) && ($0.chosen == 0) })!
                                DispatchQueue.main.async {
                                    self.rewardVC?.rewardTable.reloadData()
                                }
                            })
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        task.resume()
            
    }
    
    @objc func keyboardShow(_ notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let intersection = keyboardSize.intersection(self.view.frame)
        self.view.frame.origin.y -= intersection.height - 100
    }
    
    @objc func keyboardHide(_ notification: Notification) {
        self.view.frame.origin.y = 0
    }
    
    func keyboardHide() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardDismiss))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func keyboardDismiss() {
        self.view.endEditing(true)
    }
    
}

extension AddCaseViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
