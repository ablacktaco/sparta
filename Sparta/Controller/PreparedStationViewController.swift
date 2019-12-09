//
//  StationViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/12/8.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class PreparedStationViewController: UIViewController {

    var preparedStationGoods = [StationGoods.Result]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preparedStationGoodsTable.tableFooterView = UIView()
    }
    
    @IBOutlet var preparedStationGoodsTable: UITableView!
    
}

extension PreparedStationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preparedStationGoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "stationCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! StationTableViewCell
        
        cell.setGoodsData(preparedStationGoods, indexPath: indexPath)
        cell.setDestination(preparedStationGoods, indexPath: indexPath)
        cell.selectionStyle = .none
        
        return cell
    }
    
}
