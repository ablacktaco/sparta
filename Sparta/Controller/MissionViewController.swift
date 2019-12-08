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
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        navigationItem.title = "Mission management"
        navigationItem.backBarButtonItem?.tintColor = UIColor(red: 1/255, green: 194/255, blue: 176/255, alpha: 1)
        
        getMissionHistory { (missionHistory) in
            self.missionList = missionHistory.history!
            self.filterList = self.missionList.filter { ($0.done == 1) }
            DispatchQueue.main.async {
                self.missionTable.reloadData()
            }
        }
        
        for button in chooseButtons {
            button.alpha = 0.3
        }
        chooseButtons[0].alpha = 1
    }

    @IBOutlet var chooseButtons: [UIButton]! {
        didSet {
            for button in chooseButtons {
                setViewBorder(view: button, configSetting: .chooseButton)
            }
        }
    }
    @IBOutlet var missionTable: UITableView! {
        didSet { missionTable.tableFooterView = UIView() }
    }
    
    @IBAction func chooseSuccessfulMission(_ sender: UIButton) {
        for button in chooseButtons {
            button.alpha = 0.3
        }
        chooseButtons[0].alpha = 1
        filterList = missionList.filter { ($0.done == 1) }
        missionTable.reloadData()
    }
    @IBAction func chooseFailedMission(_ sender: UIButton) {
        for button in chooseButtons {
            button.alpha = 0.3
        }
        chooseButtons[1].alpha = 1
        filterList = missionList.filter { ($0.done == 0) }
        missionTable.reloadData()
    }
    @IBAction func chooseReportedMission(_ sender: UIButton) {
        for button in chooseButtons {
            button.alpha = 0.3
        }
        chooseButtons[2].alpha = 1
        filterList = missionList.filter { ($0.reported_descript != nil) && ($0.done == nil) }
        missionTable.reloadData()
    }
    @IBAction func chooseUnreportedMission(_ sender: UIButton) {
        for button in chooseButtons {
            button.alpha = 0.3
        }
        chooseButtons[3].alpha = 1
        filterList = missionList.filter { ($0.reported_descript == nil) && ($0.chosen == 1) }
        missionTable.reloadData()
    }
    @IBAction func chooseApplingMission(_ sender: UIButton) {
        for button in chooseButtons {
            button.alpha = 0.3
        }
        chooseButtons[4].alpha = 1
        filterList = missionList.filter { ($0.chosen == 0) }
        missionTable.reloadData()
    }
}

extension MissionViewController {
    
    func getMissionHistory(closure: @escaping (HistoryAndPosts) -> Void) {
                       
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
        let cellIdentifier = "missionCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MissionTableViewCell
            cell.setMissionData(filterList, indexPath: indexPath)
        
        if filterList[indexPath.row].reported_descript == nil && filterList[indexPath.row].chosen == 1 {
            cell.selectionStyle = .gray
        } else {
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if filterList[indexPath.row].reported_descript == nil && filterList[indexPath.row].chosen == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let reportVC = storyboard?.instantiateViewController(withIdentifier: "reportVC") as? ReportedViewController {
            reportVC.missionTitle = filterList[indexPath.row].name
            reportVC.id = filterList[indexPath.row].reward_id
            reportVC.missionVC = self
            self.navigationController?.pushViewController(reportVC, animated: true)
        }
    }
    
}
