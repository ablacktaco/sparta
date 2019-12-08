//
//  StationTableViewCell.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/12/8.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class StationTableViewCell: UITableViewCell {

    var downloadCompletionBlock: ((_ data: Data) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBOutlet var goodsName: UILabel!
    @IBOutlet var goodsState: UILabel!
    @IBOutlet var goodsImage: UIImageView!
    
}

extension StationTableViewCell {
    
    func setGoodsData(_ goods: [StationGoods.Result], indexPath: IndexPath) {
        goodsName.text = goods[indexPath.row].name
        goodsState.text = goods[indexPath.row].status
        downloadByDownloadTask(urlString: goods[indexPath.row].photo_url, completion: { (data) in
            self.goodsImage.image = UIImage(data: data)
        })
    }
    
    func downloadByDownloadTask(urlString: String?, completion: @escaping (Data) -> Void){
        if let urlString = urlString {
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
    
}

extension StationTableViewCell: URLSessionDownloadDelegate {
    
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
