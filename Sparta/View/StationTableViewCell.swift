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

    @IBOutlet var goodsImage: UIImageView!
    @IBOutlet var goodsName: UILabel!
    @IBOutlet var goodsDestination: UILabel!
    @IBOutlet var goodsLocation: UILabel!
    
}

extension StationTableViewCell {
    
    func setGoodsData(_ goods: [StationGoods.Result], indexPath: IndexPath) {
        goodsName.text = goods[indexPath.row].name
        downloadByDownloadTask(urlString: goods[indexPath.row].photo_url, completion: { (data) in
            self.goodsImage.image = UIImage(data: data)
        })
    }
    
    func setLocation(_ goods: [StationGoods.Result], indexPath: IndexPath) {
        switch goods[indexPath.row].now_station_id {
        case 1: goodsLocation.text = "Location: Athens"
        case 2: goodsLocation.text = "Location: Phokis - Athens"
        case 3: goodsLocation.text = "Location: Arkadia - Phokis"
        case 4: goodsLocation.text = "Location: Sparta - Arkadia"
        default: break
        }
    }
    
    func setDestination(_ goods: [StationGoods.Result], indexPath: IndexPath) {
        switch goods[indexPath.row].des_station_id {
        case 1: goodsDestination.text = "Destination: Athens"
        case 2: goodsDestination.text = "Destination: Phokis"
        case 3: goodsDestination.text = "Destination: Arkadia"
        case 4: goodsDestination.text = "Destination: Sparta"
        default: break
        }
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
