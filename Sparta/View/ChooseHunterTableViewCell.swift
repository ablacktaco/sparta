//
//  ChooseHunterTableViewCell.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/26.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class ChooseHunterTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBOutlet var hunterName: UILabel!
    @IBOutlet var hunterFee: UILabel!
    @IBOutlet var hunterRate: UILabel!
    @IBOutlet var hunterExp: UILabel!
    
}

extension ChooseHunterTableViewCell {
    
    func setHunterData(_ hunters: [Reward.Hunter], indexPath: IndexPath) {
        hunterName.text = hunters[indexPath.row].name
        hunterFee.text = "Offer price: $\(hunters[indexPath.row].fee)"
        if hunters[indexPath.row].experience == 0 {
            hunterRate.text = "Achieve rate: 0 %"
        } else {
            hunterRate.text = "Achieve rate: \(hunters[indexPath.row].achieveRate / hunters[indexPath.row].experience * 100) %"
        }
        hunterExp.text = "Finished case: \(hunters[indexPath.row].experience)"
    }
    
}
