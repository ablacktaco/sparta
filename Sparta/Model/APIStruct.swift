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
    var bank_account: String
}

struct DecodeRegister: Codable {
    var result: String
}

struct Bank: Codable {
    var name: String
    var account: String
    var password: String
}

struct DecodeBank: Codable {
    var key: Int
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
    
    var avatar: String?
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
    var img: String?
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
        var achieveRate: Int
        var experience: Int
    }
}

struct RewardData: Codable {
    var reward: [Reward]
}

struct HistoryAndPosts: Codable {
    
    var history: [History]?
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

struct AddMission: Codable {
    
    var name: String
    var category: Int
    var budget: Int
    var descript: String
    
}

struct OfferPrice: Codable {
    
    var fee: Int
    
}

struct HunterID: Codable {
    
    var user_reward_id: Int
    
}

struct FinishMission: Codable {
    
    var done: Int
    var key: String?
    
}

struct Goods: Codable {
    
    var result: [Result]
    
    struct Result: Codable {
        var id: Int
        var item_name: String
        var price: Int
        var stock: Int
        var pic: String?
    }
    
}

struct BuyGoods: Codable {
    
    var item_id: Int
    var count: Int
    var key: String
    
}

struct EarnMoney: Codable {
    
    var earned: Int
    
}

struct Belongings: Codable {
    
    var id: Int
    var name: String
    var img: String?
    
}

struct SendGoods: Codable {
    
    var des_station_name: String
    var weight: Double
    var price: Int
    
}

struct StationGoods: Codable {
    
    var result: [Result]
    
    struct Result: Codable {
        
        var name: String
        var des_station_id: Int
        var now_station_id: Int
        var status: String
        var photo_url: String?
        
    }
    
}

struct BankUserData: Codable {
    
    var userID: String
    var password: String
    
}
