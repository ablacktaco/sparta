//
//  RewardTableViewCell.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/25.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class RewardTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBOutlet var rewardName: UILabel!
    @IBOutlet var rewardDescription: UILabel!
    @IBOutlet var rewardBonus: UILabel!
    @IBOutlet var rewardType: UIImageView!
    
}

extension RewardTableViewCell {
    
    func setRewardData(_ rewardList: [RewardData.Reward], indexPath: IndexPath) {
        rewardName.text = rewardList[indexPath.row].name
        rewardDescription.text = rewardList[indexPath.row].descript
        rewardBonus.text = "Bonus: $\(rewardList[indexPath.row].bonus)"
        if rewardList[indexPath.row].category == 1 {
            rewardType.image = UIImage(named: "kill")
        } else {
            rewardType.image = UIImage(named: "collect")
        }
    }
    
}
