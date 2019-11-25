//
//  RewardViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/25.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class RewardViewController: UIViewController {

    var rewardList = [RewardData.Reward]()
    var undoRewardList = [RewardData.Reward]()
    var searchRewardList = [RewardData.Reward]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getRewardData { (rewardData) in
            self.rewardList = rewardData.reward
            self.undoRewardList = self.rewardList.filter { ($0.done == 0) }
            DispatchQueue.main.async {
                self.rewardTable.reloadData()
            }
        }
        
        navigationItem.title = "Reward"
        navigationController?.navigationBar.tintColor = UIColor(red: 1/255, green: 194/255, blue: 176/255, alpha: 1)
        
        searchController.searchBar.placeholder = "Enter mission or lower limit of bonus..."
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

    }
    
    @IBOutlet var rewardTable: UITableView!
    
}

extension RewardViewController {
    
    func getRewardData(closure: @escaping (RewardData) -> Void) {
                       
        let url = URL(string: "http://35.221.252.120/api/reward")!
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
                    if let rewardData = try? JSONDecoder().decode(RewardData.self, from: data) {
                        closure(rewardData)
                    }
                }
            }
        }
        task.resume()
    }
    
}

extension RewardViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text!
        if let searchBonus = Int(searchString) {
            searchRewardList = undoRewardList.filter { ($0.bonus >= searchBonus) }
        } else {
            searchRewardList = undoRewardList.filter { ($0.name.contains(searchString)) }
        }
        rewardTable.reloadData()
    }
    
}

extension RewardViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if navigationItem.searchController?.isActive == true {
            return searchRewardList.count
        } else {
            return undoRewardList.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "rewardCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RewardTableViewCell
        if navigationItem.searchController?.isActive == true {
            cell.setRewardData(searchRewardList, indexPath: indexPath)
        } else {
            cell.setRewardData(undoRewardList, indexPath: indexPath)
        }
        
        return cell
    }
    
    
}
