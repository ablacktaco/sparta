//
//  ShoppingTableViewCell.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/27.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class ShoppingTableViewCell: UITableViewCell {

    var downloadCompletionBlock: ((_ data: Data) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBOutlet var shoppingName: UILabel!
    @IBOutlet var shoppingTime: UILabel!
    @IBOutlet var shoppingImage: UIImageView!
    
}

extension ShoppingTableViewCell {
    
    func setShoppingData(_ shoppingList: [ShoppingList], indexPath: IndexPath) {
        shoppingName.text = shoppingList[indexPath.row].name
        shoppingTime.text = "Purchase time: \(shoppingList[indexPath.row].created_at)"
        downloadByDownloadTask(urlString: shoppingList[indexPath.row].img, completion: { (data) in
            self.shoppingImage.image = UIImage(data: data)
        })
    }
    
    func downloadByDownloadTask(urlString: String, completion: @escaping (Data) -> Void){
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        let configiguration = URLSessionConfiguration.default
        configiguration.timeoutIntervalForRequest = .infinity
        
        let urlSession = URLSession(configuration: configiguration, delegate: self, delegateQueue: OperationQueue.main)
        
        let task = urlSession.downloadTask(with: request)
        
        downloadCompletionBlock = completion
        
        task.resume()
    }
    
}

extension ShoppingTableViewCell: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let data = try! Data(contentsOf: location)
        if let block = downloadCompletionBlock {
            block(data)
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print(progress)
    }
    
}
