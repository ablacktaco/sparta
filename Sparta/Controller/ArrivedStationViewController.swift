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
        
        arrivedStationGoodsTable.tableFooterView = UIView()
    }
    
    @IBOutlet var arrivedStationGoodsTable: UITableView!
    
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
