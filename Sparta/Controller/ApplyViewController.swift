//
//  ApplyViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/27.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class ApplyViewController: UIViewController {

    var id: Int?
    var missionName: String?
    var rewardVC: RewardViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Apply Mission"
        
        priceText.keyboardType = .numberPad
        
        applyButton.alpha = 0.2
        applyButton.isEnabled = false
        
        priceText.addTarget(self, action: #selector(checkContent), for: .editingChanged)

    }
    
    @IBOutlet var missionTitle: UILabel! {
        didSet { missionTitle.text = missionName }
    }
    @IBOutlet var priceText: UITextField!
    @IBOutlet var applyButton: UIButton! {
        didSet { setViewBorder(view: applyButton, configSetting: .mainButton) }
    }
    @IBAction func tapToApply(_ sender: UIButton) {
        applyMission()
    }
    
}

extension ApplyViewController {
    
    @objc func checkContent() {
        if getEffectiveText(priceText) == "" {
            applyButton.alpha = 0.2
            applyButton.isEnabled = false
        } else {
            applyButton.alpha = 1
            applyButton.isEnabled = true
        }
    }
    
    func getEffectiveText(_ textField: UITextField) -> String {
        return textField.text!.trimmingCharacters(in: .whitespaces)
    }
    
    func applyMission() {
    
        let offerPrice = OfferPrice(fee: Int(priceText.text!)!)
        guard let uploadData = try? JSONEncoder().encode(offerPrice) else { return }
        
        let url = URL(string: "http://35.221.252.120/api/reward/\(id!)")!
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

extension ApplyViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
