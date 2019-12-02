//
//  GoodsViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/27.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class GoodsViewController: UIViewController {

    var goodsList = [Goods.Result]()
    var key: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getgoodsData { (goods) in
            self.goodsList = goods.result
            DispatchQueue.main.async {
                self.goodsTable.reloadData()
            }
        }
    }
    @IBOutlet var goodsTable: UITableView!
}

extension GoodsViewController {
    
    func getgoodsData(closure: @escaping (Goods) -> Void) {
                       
        let url = URL(string: "http://35.221.252.120/api/shop")!
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
                    if let goodsData = try? JSONDecoder().decode(Goods.self, from: data) {
                        closure(goodsData)
                    }
                }
            }
        }
        task.resume()
    }
    
    func buyGoods(_ indexPath: IndexPath) {
        let goods = BuyGoods(item_id: goodsList[indexPath.row].id, count: 1, key: key!)
        guard let uploadData = try? JSONEncoder().encode(goods) else { return }
            
        let url = URL(string: "http://35.221.252.120/api/buy")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("keep-alive", forHTTPHeaderField: "connection")
        request.setValue(UserData.shared.token, forHTTPHeaderField: "remember_token")
                            
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
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
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                            self.getgoodsData { (goods) in
                                self.goodsList = goods.result
                                DispatchQueue.main.async {
                                    self.goodsTable.reloadData()
                                }
                            }
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        task.resume()
    }
    
}

extension GoodsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goodsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "goodsCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! GoodsTableViewCell
        
        cell.setGoodsData(goodsList, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Vertify", message: "Enter your bank key:", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter your bank account's key..."
        }
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.key = alertController.textFields?[0].text
            self.buyGoods(indexPath)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
