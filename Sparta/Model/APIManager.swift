//
//  GetAPI.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/25.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import Foundation

private let baseUrl = "http://34.80.65.255/api/"

protocol APIManager {
    var path: String { get }
    var httpMethod: HTTPMethod { get }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
