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

struct UserInfo: Codable {
    var id: Int
    var achieveRate: Int?
    var experience: Int?
    var money: Int
    var cost: Int
}

struct Reward: Codable {
    var id: Int
    var descript: String
    var name: String
    var reported_descript: String?
    var hunters: [Hunter]
    var budget: Int
    var category: Int
    var done: Int?
    var chosen: Int
    var user_id: Int
    
    struct Hunter: Codable {
        var name: String
        var user_rewards_id: Int
        var fee: Int
    }
}

struct RewardData: Codable {
    var reward: [Reward]
}

struct HistoryAndPosts: Codable {
    
    var history: [History]
    var posts: [Reward]
    
    struct History: Codable {
        var reward_id: Int
        var name: String
        var category: Int
        var descript: String
        var reported_descript: String?
        var fee: Int
        var chosen: Int
        var done: Int?
    }
    
}
