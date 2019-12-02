//
//  ShoppingViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/27.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class ShoppingViewController: UIViewController {

    var shoppingList = [ShoppingList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getShopList { (shoppingList) in
            self.shoppingList = shoppingList
            DispatchQueue.main.async {
                self.shoppingTable.reloadData()
            }
        }
    }
    
    @IBOutlet var shoppingTable: UITableView!
    
}

extension ShoppingViewController {
    
    func getShopList(closure: @escaping ([ShoppingList]) -> Void) {
        
        let url = URL(string: "http://35.221.252.120/api/bought")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("keep-alive", forHTTPHeaderField: "connection")
        request.setValue(UserData.shared.token, forHTTPHeaderField: "remember_token")
                        
        let task = URLSession.shared.uploadTask(with: request, fromFile: url) { (data, response, error) in
            if let error = error {
                print ("error: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("status code: \(response.statusCode)")
                if let mimeType = response.mimeType,
                    mimeType == "application/json",
                    let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    print ("got data: \(dataString)")
                    if let shoppingList = try? JSONDecoder().decode([ShoppingList].self, from: data) {
                        closure(shoppingList)
                    }
                }
            }
        }
        task.resume()
    }
    
}

extension ShoppingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "shoppingCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ShoppingTableViewCell
        
        cell.setShoppingData(shoppingList, indexPath: indexPath)
        
        return cell
    }
    
}
