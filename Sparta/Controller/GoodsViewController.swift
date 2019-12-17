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
    var keyAlert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goodsTable.tableFooterView = UIView()
        
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
                       
        let url = URL(string: "http://34.80.65.255/api/shop")!
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
            
        let url = URL(string: "http://34.80.65.255/api/buy")!
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
                if response.statusCode != 200 {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Error", message: "Wrong key", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
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
    
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        keyAlert!.actions[0].isEnabled = sender.text!.count > 0
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
        cell.selectionStyle = .gray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if goodsList[indexPath.row].stock == 0 {
            let alertController = UIAlertController(title: "Error", message: "The goods is out of stock.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        } else {
            keyAlert = UIAlertController(title: "Vertify", message: nil, preferredStyle: .alert)
            keyAlert!.addTextField { (textField) in
                textField.placeholder = "Enter your bank's key"
                textField.isSecureTextEntry = true
                textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
            }
            keyAlert!.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                self.key = self.keyAlert!.textFields?[0].text
                self.buyGoods(indexPath)
            }))
            keyAlert?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            keyAlert?.actions[0].isEnabled = false
            self.present(keyAlert!, animated: true, completion: nil)
        }
    }
    
}
