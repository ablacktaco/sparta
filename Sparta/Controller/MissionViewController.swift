//
//  MercenaryViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/26.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class MissionViewController: UIViewController {

    var missionList = [HistoryAndPosts.History]()
    var filterList = [HistoryAndPosts.History]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMissionHistory { (missionHistory) in
            self.missionList = missionHistory.history
            self.filterList = self.missionList.filter { ($0.done == 1) }
            DispatchQueue.main.async {
                self.missionTable.reloadData()
            }
        }
        
        navigationItem.title = "Mission History"
        navigationController?.navigationBar.tintColor = UIColor(red: 1/255, green: 194/255, blue: 176/255, alpha: 1)
    }

    @IBOutlet var chooseButtons: [UIButton]! {
        didSet {
            for button in chooseButtons {
                setViewBorder(view: button, configSetting: .chooseButton)
            }
        }
    }
    @IBOutlet var missionTable: UITableView!
}

extension MissionViewController {
    
    func getMissionHistory(closure: @escaping (HistoryAndPosts) -> Void) {
                       
        let url = URL(string: "http://35.221.252.120/api/history")!
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
                    if let missionHistory = try? JSONDecoder().decode(HistoryAndPosts.self, from: data) {
                        closure(missionHistory)
                    }
                }
            }
        }
        task.resume()
    }
    
    
}

extension MissionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "rewardCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RewardTableViewCell
//        if navigationItem.searchController?.isActive == true {
//            cell.setRewardData(searchRewardList, indexPath: indexPath)
//        } else {
//            cell.setRewardData(undoRewardList, indexPath: indexPath)
//        }
        
        return cell
    }
    
}
