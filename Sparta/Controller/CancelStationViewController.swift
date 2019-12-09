//
//  CanaelStationViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/12/9.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class CancelStationViewController: UIViewController {

    var cancelStationGoods = [StationGoods.Result]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cancelStationGoodsTable.tableFooterView = UIView()
    }
    
    @IBOutlet var cancelStationGoodsTable: UITableView!

}

extension CancelStationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cancelStationGoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "stationCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! StationTableViewCell
        
        cell.setGoodsData(cancelStationGoods, indexPath: indexPath)
        cell.setLocation(cancelStationGoods, indexPath: indexPath)
        cell.selectionStyle = .none
        
        return cell
    }
    
}
