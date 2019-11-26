//
//  MissionTableViewCell.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/26.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class MissionTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBOutlet var missionName: UILabel!
    @IBOutlet var missionDescription: UILabel!
    @IBOutlet var missionBonus: UILabel!
    @IBOutlet var missionType: UIImageView!
    
}

extension MissionTableViewCell {
    
    func setMissionData(_ missionList: [HistoryAndPosts.History], indexPath: IndexPath) {
        missionName.text = missionList[indexPath.row].name
        missionDescription.text = missionList[indexPath.row].descript
        missionBonus.text = "Bonus: $\(missionList[indexPath.row].fee)"
        if missionList[indexPath.row].category == 1 {
            missionType.image = UIImage(named: "kill")
        } else {
            missionType.image = UIImage(named: "collect")
        }
    }
    
}
