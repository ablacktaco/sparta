//
//  ChooseHunterViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/26.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class ChooseHunterViewController: UIViewController {

    var id: Int?
    var hunters = [Reward.Hunter]()
    var index: Int?
    var mercenaryVC: PostViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assignedButton.alpha = 0.2
        assignedButton.isEnabled = false
        
        navigationItem.title = "Asigned hunter"
        hunterTable.tableFooterView = UIView()
    }
    
    @IBOutlet var hunterTable: UITableView!
    @IBOutlet var assignedButton: UIButton! {
        didSet { setViewBorder(view: assignedButton, configSetting: .mainButton) }
    }
    @IBAction func comfirmButton(_ sender: UIButton) {
        chooseHunter()
    }
    
}

extension ChooseHunterViewController {
    
    func chooseHunter() {
        
        let hunterID = HunterID(user_reward_id: hunters[index!].user_rewards_id)
        guard let uploadData = try? JSONEncoder().encode(hunterID) else { return }
        
        let url = URL(string: "http://34.80.65.255/api/reward/\(id!)/choose")!
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
                            self.mercenaryVC?.getRewardHistory(closure: { (rewardHistory) in
                                self.mercenaryVC?.rewardList = rewardHistory.posts
                                self.mercenaryVC?.filterList = (self.mercenaryVC?.rewardList.filter { ($0.done == 1) })!
                                DispatchQueue.main.async {
                                    self.mercenaryVC?.rewardTable.reloadData()
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


extension ChooseHunterViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hunters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "hunterCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ChooseHunterTableViewCell
        cell.setHunterData(hunters, indexPath: indexPath)
        cell.selectionStyle = .gray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        assignedButton.isEnabled = true
        assignedButton.alpha = 1
        index = indexPath.row
    }
    
}
