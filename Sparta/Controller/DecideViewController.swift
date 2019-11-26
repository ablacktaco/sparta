//
//  DecideViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/27.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class DecideViewController: UIViewController {

    var id: Int?
    var done: Int?
    var downloadCompletionBlock: ((_ data: Data) -> Void)?
    let downLoadURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadByDownloadTask(urlString: downLoadURL, completion: { (data) in
            self.reportedImage.image = UIImage(data: data)
        })
    }
    
    @IBOutlet var reportedImage: UIImageView!
    @IBAction func missionSuccess(_ sender: UIButton) {
        done = 1
        finishMission()
    }
    @IBAction func missionFail(_ sender: UIButton) {
        done = 0
        finishMission()
    }

}

extension DecideViewController {
    
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
    
    func finishMission() {
        
        let finishCondition = FinishMission(done: done!)
        guard let uploadData = try? JSONEncoder().encode(finishCondition) else { return }
        
        let url = URL(string: "http://35.221.252.120/api/reward/\(id!)/done")!
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
                }
            }
        }
        task.resume()
        
    }
    
}

extension DecideViewController: URLSessionDownloadDelegate {
    
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
