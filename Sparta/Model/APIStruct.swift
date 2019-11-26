//
//  APIStruct.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/25.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import Foundation

struct Register: Codable {
    var name: String
    var account: String
    var password: String
    var role: Int
}

struct DecodeRegister: Codable {
    var result: String
}

struct SignIn: Codable {
    var account: String
    var password: String
}

struct DecodeSignIn: Codable {
    var user: User
    struct User: Codable {
        var name: String
        var role: Int
        var remember_token: String
    }
}

struct UserMoney: Codable {
    var money: Int
    var cost: Int
}

struct RewardData: Codable {
    var reward: [Reward]
    struct Reward: Codable {
        var id: Int
        var descript: String
        var name: String
        var hunters: [Hunter]
        var budget: Int
        var category: Int
        var done: Int
        
        struct Hunter: Codable {
            var id: Int
            var name: String
            var bonus: Int
        }
    }
}
