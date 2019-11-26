//
//  Properties.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/25.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

struct BorderProperties {
    
    static let mainButton = BorderProperties(cornerRadius: 25, borderWidth: 2)
    static let chooseButton = BorderProperties(cornerRadius: 20, borderWidth: 1.5)
    
    var cornerRadius: Double = 0
    var bordercolor: CGColor = #colorLiteral(red: 0.003921568627, green: 0.7607843137, blue: 0.6901960784, alpha: 1)
    var borderWidth: Double = 0
    
}

func setViewBorder(view: UIView, configSetting: BorderProperties) {
    view.layer.cornerRadius = CGFloat(configSetting.cornerRadius)
    view.layer.borderColor = configSetting.bordercolor
    view.layer.borderWidth = CGFloat(configSetting.borderWidth)
    view.clipsToBounds = true
}
