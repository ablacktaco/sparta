//
//  SendingStationViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/12/9.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class SendingStationViewController: UIViewController {

    var sendingStationGoods = [StationGoods.Result]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sendingStationGoodsTable.tableFooterView = UIView()
    }
    
    @IBOutlet var sendingStationGoodsTable: UITableView!

}

extension SendingStationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sendingStationGoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "stationCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! StationTableViewCell
        
        cell.setGoodsData(sendingStationGoods, indexPath: indexPath)
        cell.setLocation(sendingStationGoods, indexPath: indexPath)
        cell.setDestination(sendingStationGoods, indexPath: indexPath)
        cell.selectionStyle = .none
        
        return cell
    }
    
}
