//
//  ArrivedStationViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/12/9.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class ArrivedStationViewController: UIViewController {

    var arrivedStationGoods = [StationGoods.Result]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getStationGoods { (stationGoods) in
            self.arrivedStationGoods = stationGoods.result.filter { ($0.status == "已抵達") }
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.loadingTable.alpha = 0
                }
                if self.arrivedStationGoods.count == 0 {
                    self.arrivedStationGoodsTable.backgroundView = self.noGoodsView
                }
                
                self.arrivedStationGoodsTable.reloadData()
            }
        }
        
        arrivedStationGoodsTable.tableFooterView = UIView()
    }

    @IBOutlet var loadingTable: UIActivityIndicatorView!
    @IBOutlet var arrivedStationGoodsTable: UITableView!
    @IBOutlet var noGoodsView: UIView!
    
}

extension ArrivedStationViewController {
    
    func getStationGoods(closure: @escaping (StationGoods) -> Void) {
                       
        let url = URL(string: "http://34.80.65.255/api/goodlist/4")!
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

extension ArrivedStationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrivedStationGoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "stationCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! StationTableViewCell
        
        cell.setGoodsData(arrivedStationGoods, indexPath: indexPath)
        cell.selectionStyle = .none
        
        return cell
    }
    
}
