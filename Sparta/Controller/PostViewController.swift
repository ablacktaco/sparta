//
//  MortalViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/26.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    var rewardList = [Reward]()
    var filterList = [Reward]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Post management"
        
        for button in chooseButtons {
            button.alpha = 0.3
        }
        chooseButtons[0].alpha = 1
        
        rewardTable.tableFooterView = UIView()
        
        getRewardHistory { (rewardHistory) in
            self.rewardList = rewardHistory.posts
            self.filterList = self.rewardList.filter { ($0.done == 1) }
            print(self.filterList)
            DispatchQueue.main.async {
                self.rewardTable.reloadData()
            }
        }
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        navigationItem.backBarButtonItem?.tintColor = UIColor(red: 1/255, green: 194/255, blue: 176/255, alpha: 1)
    }
    
    @IBOutlet var chooseButtons: [UIButton]! {
        didSet {
            for button in chooseButtons {
                setViewBorder(view: button, configSetting: .chooseButton)
            }
        }
    }
    @IBOutlet var rewardTable: UITableView!
    
    @IBAction func chooseSuccessfulMission(_ sender: UIButton) {
        for button in chooseButtons {
            button.alpha = 0.3
        }
        chooseButtons[0].alpha = 1
        filterList = rewardList.filter { ($0.done == 1) }
        rewardTable.reloadData()
    }
    @IBAction func chooseFailedMission(_ sender: UIButton) {
        for button in chooseButtons {
            button.alpha = 0.3
        }
        chooseButtons[1].alpha = 1
        filterList = rewardList.filter { ($0.done == 0) }
        rewardTable.reloadData()
    }
    @IBAction func chooseAssignedMission(_ sender: UIButton) {
        for button in chooseButtons {
            button.alpha = 0.3
        }
        chooseButtons[2].alpha = 1
        filterList = rewardList.filter { ($0.chosen == 1) && ($0.reported_descript == nil) }
        rewardTable.reloadData()
    }
    @IBAction func chooseUnassignedMission(_ sender: UIButton) {
        for button in chooseButtons {
            button.alpha = 0.3
        }
        chooseButtons[3].alpha = 1
        filterList = rewardList.filter { ($0.chosen == 0) }
        rewardTable.reloadData()
    }
    @IBAction func chooseReportedMission(_ sender: UIButton) {
        for button in chooseButtons {
            button.alpha = 0.3
        }
        chooseButtons[4].alpha = 1
        filterList = rewardList.filter { ($0.reported_descript != nil) && $0.done == nil }
        rewardTable.reloadData()
    }
    
}

extension PostViewController {
    
    func getRewardHistory(closure: @escaping (HistoryAndPosts) -> Void) {
                       
        let url = URL(string: "http://34.80.65.255/api/history")!
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
                    if let rewardHistory = try? JSONDecoder().decode(HistoryAndPosts.self, from: data) {
                        closure(rewardHistory)
                    }
                }
            }
        }
        task.resume()
    }
    
}

extension PostViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "mortalCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PostTableViewCell
        
        cell.setRewardData(filterList, indexPath: indexPath)
        
        if filterList[indexPath.row].chosen == 0 {
            cell.selectionStyle = .gray
        } else if filterList[indexPath.row].reported_descript != nil && filterList[indexPath.row].done == nil {
            cell.selectionStyle = .gray
        } else {
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filterList[indexPath.row].chosen == 0 {
            if let chooseVC = storyboard?.instantiateViewController(withIdentifier: "chooseVC") as? ChooseHunterViewController {
                chooseVC.mercenaryVC = self
                chooseVC.hunters = filterList[indexPath.row].hunters
                chooseVC.id = filterList[indexPath.row].id
                self.navigationController?.pushViewController(chooseVC, animated: true)
            }
        } else if filterList[indexPath.row].reported_descript != nil && filterList[indexPath.row].done == nil {
            if let decideVC = storyboard?.instantiateViewController(withIdentifier: "decideVC") as? DecideViewController {
                decideVC.mercenaryVC = self
                decideVC.id = filterList[indexPath.row].id
                decideVC.missionTitle = filterList[indexPath.row].name
                decideVC.img = filterList[indexPath.row].img
                decideVC.repDe = filterList[indexPath.row].reported_descript
                self.navigationController?.pushViewController(decideVC, animated: true)
            }
        }
    }
    
}
