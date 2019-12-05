//
//  RewardViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/25.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class RewardViewController: UIViewController {

    var offerAlert: UIAlertController?
    
    var rewardList = [Reward]()
    var undoRewardList = [Reward]()
    var searchRewardList = [Reward]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        rewardTable.tableFooterView = UIView()
        
        getRewardData { (rewardData) in
            self.rewardList = rewardData.reward
            self.undoRewardList = self.rewardList.filter { ($0.done == nil) && ($0.chosen == 0) }
            DispatchQueue.main.async {
                self.rewardTable.reloadData()
            }
        }
        
        navigationItem.title = "Reward"
        navigationController?.navigationBar.tintColor = UIColor(red: 1/255, green: 194/255, blue: 176/255, alpha: 1)
        
        searchController.searchBar.placeholder = "Enter mission or lower budget"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

    }
    
    @IBOutlet var rewardTable: UITableView!
    @IBAction func tapToPassAddPage(_ sender: UIBarButtonItem) {
        if let addVC = storyboard?.instantiateViewController(withIdentifier: "addVC") as? AddCaseViewController {
            addVC.rewardVC = self
            self.navigationController?.pushViewController(addVC, animated: true)
        }
    }
    
}

extension RewardViewController {
    
    func getRewardData(closure: @escaping (RewardData) -> Void) {
                       
        let url = URL(string: "http://34.80.65.255/api/reward")!
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
    
    func applyMission(_ id: Int, price: Int) {

        let offerPrice = OfferPrice(fee: price)
        guard let uploadData = try? JSONEncoder().encode(offerPrice) else { return }

        let url = URL(string: "http://34.80.65.255/api/reward/\(id)")!
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
                            self.getRewardData(closure: { (rewardData) in
                                self.rewardList = rewardData.reward
                                self.undoRewardList = self.rewardList.filter { ($0.done == nil) && ($0.chosen == 0) }
                                DispatchQueue.main.async {
                                    self.rewardTable.reloadData()
                                }
                            })
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        offerAlert!.actions[0].isEnabled = sender.text!.count > 0
    }
}

extension RewardViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text!
        if let searchBonus = Int(searchString) {
            searchRewardList = undoRewardList.filter { ($0.budget >= searchBonus) }
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
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if UserData.shared.role == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if navigationItem.searchController?.isActive == true {
            if UserData.shared.id == searchRewardList[indexPath.row].user_id {
                let alertController = UIAlertController(title: "You can't apply your own case.", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                offerAlert = UIAlertController(title: searchRewardList[indexPath.row].name, message: nil, preferredStyle: .alert)
                offerAlert!.addTextField { (textField) in
                    textField.placeholder = "Enter your price"
                    textField.keyboardType = .numberPad
                    textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
                }
                offerAlert!.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.applyMission(self.searchRewardList[indexPath.row].id, price: Int((self.offerAlert?.textFields?[0].text)!)!)
                }))
                offerAlert!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                offerAlert?.actions[0].isEnabled = false
                self.present(offerAlert!, animated: true, completion: nil)
            }
        } else {
            if UserData.shared.id == undoRewardList[indexPath.row].user_id {
                let alertController = UIAlertController(title: "You can't apply your own case.", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                offerAlert = UIAlertController(title: undoRewardList[indexPath.row].name, message: nil, preferredStyle: .alert)
                offerAlert!.addTextField { (textField) in
                    textField.placeholder = "Enter your price"
                    textField.keyboardType = .numberPad
                    textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
                }
                offerAlert!.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.applyMission(self.undoRewardList[indexPath.row].id, price: Int((self.offerAlert?.textFields?[0].text)!)!)
                }))
                offerAlert!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                offerAlert?.actions[0].isEnabled = false
                self.present(offerAlert!, animated: true, completion: nil)
            }
        }
    }
    
}

