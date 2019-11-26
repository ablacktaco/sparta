//
//  UserData.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/25.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import Foundation

struct UserData {
    
    static var shared = UserData()
    
    var id: Int?
    var name: String?
    var role: Int?
    var token: String?
    
    private init() {}
    
}
