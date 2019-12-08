//
//  StationViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/12/8.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class StationViewController: UIViewController {

    var stationGoods = [StationGoods.Result]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = UIColor(red: 1/255, green: 194/255, blue: 176/255, alpha: 1)
        
        stationGoodsTable.tableFooterView = UIView()
        
        getstationGoods { (stationGoods) in
            self.stationGoods = stationGoods.result
            DispatchQueue.main.async {
                self.stationGoodsTable.reloadData()
            }
        }
    }
    
    @IBOutlet var stationGoodsTable: UITableView!
    

}

extension StationViewController {
    
    func getstationGoods(closure: @escaping (StationGoods) -> Void) {
                       
        let url = URL(string: "http://34.80.65.255/api/tasklist/3")!
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
                    if let stationGoods = try? JSONDecoder().decode(StationGoods.self, from: data) {
                        closure(stationGoods)
                    }
                }
            }
        }
        task.resume()
    }
    
}

extension StationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationGoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "stationCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! StationTableViewCell
        
        cell.setGoodsData(stationGoods, indexPath: indexPath)
        cell.selectionStyle = .none
        
        return cell
    }
    
    
}
