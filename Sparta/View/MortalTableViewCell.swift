//
//  MortalTableViewCell.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/27.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class MortalTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBOutlet var rewardName: UILabel!
    @IBOutlet var rewardDescription: UILabel!
    @IBOutlet var rewardBudget: UILabel!
    @IBOutlet var rewardCompetitor: UILabel!
    @IBOutlet var rewardType: UIImageView!
        
}

extension MortalTableViewCell {
        
    func setRewardData(_ rewardList: [Reward], indexPath: IndexPath) {
        rewardName.text = rewardList[indexPath.row].name
        rewardDescription.text = rewardList[indexPath.row].descript
        rewardBudget.text = "Budget: $\(rewardList[indexPath.row].budget)"
        if rewardList[indexPath.row].hunters.count != 0 {
            rewardCompetitor.text = "Hunter: "
            for hunter in rewardList[indexPath.row].hunters {
                rewardCompetitor.text = rewardCompetitor.text! + hunter.name + ","
            }
        } else {
            rewardCompetitor.text = "Hunter: Nobody"
        }
        if rewardList[indexPath.row].category == 1 {
            rewardType.image = UIImage(named: "kill")
        } else {
            rewardType.image = UIImage(named: "collect")
        }
    }
        
}
