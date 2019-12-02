//
//  GoodsTableViewCell.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/27.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class GoodsTableViewCell: UITableViewCell {

    var downloadCompletionBlock: ((_ data: Data) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBOutlet var goodsName: UILabel!
    @IBOutlet var goodsPrice: UILabel!
    @IBOutlet var goodsStock: UILabel!
    @IBOutlet var goodsImage: UIImageView!
    
}

extension GoodsTableViewCell {
    
    func setGoodsData(_ goodsList: [Goods.Result], indexPath: IndexPath) {
        goodsName.text = goodsList[indexPath.row].item_name
        goodsPrice.text = "Price: \(goodsList[indexPath.row].price)"
        goodsStock.text = "Stock: \(goodsList[indexPath.row].stock)"
        downloadByDownloadTask(urlString: goodsList[indexPath.row].pic, completion: { (data) in
            self.goodsImage.image = UIImage(data: data)
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

extension GoodsTableViewCell: URLSessionDownloadDelegate {
    
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
