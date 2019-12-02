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

        navigationItem.title = "Add Mission"
        
        missionBudget.keyboardType = .numberPad
        
        addButton.alpha = 0.2
        addButton.isEnabled = false
        
        missionName.addTarget(self, action: #selector(checkContent), for: .editingChanged)
        missionBudget.addTarget(self, action: #selector(checkContent), for: .editingChanged)
    }
    
    @IBOutlet var missionName: UITextField!
    @IBOutlet var missionBudget: UITextField!
    @IBOutlet var missionType: UISegmentedControl!
    @IBOutlet var missionDescription: UITextView!
    @IBOutlet var addButton: UIButton! {
        didSet { setViewBorder(view: addButton, configSetting: .mainButton) }
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
        
        let missionData = AddMission(name: missionName.text!, category: missionType.selectedSegmentIndex + 1, budget: Int( missionBudget.text!)!, descript: missionDescription.text)
        guard let uploadData = try? JSONEncoder().encode(missionData) else { return }
            
        let url = URL(string: "http://35.221.252.120/api/reward/")!
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
        
}

extension AddCaseViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
