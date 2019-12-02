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
    var img: String?
    var done: Int?
    var repDe: String?
    var downloadCompletionBlock: ((_ data: Data) -> Void)?
    var mercenaryVC: MercenaryViewController?
    var missionTitle: String?
    
    var key: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadByDownloadTask(urlString: img!, completion: { (data) in
            self.reportedImage.image = UIImage(data: data)
        })
    }
    
    @IBOutlet var titleLabel: UILabel! {
        didSet { titleLabel.text = missionTitle }
    }
    @IBOutlet var reportedImage: UIImageView!
    @IBOutlet var reportedDescription: UILabel! {
        didSet { reportedDescription.text = repDe }
    }
    @IBOutlet var decideButtons: [UIButton]! {
        didSet {
            for button in decideButtons {
                setViewBorder(view: button, configSetting: .mainButton)
            }
        }
    }
    @IBAction func missionSuccess(_ sender: UIButton) {
        done = 1
        let alertController = UIAlertController(title: "Vertify", message: "Enter your bank key:", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter your bank account's key..."
        }
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.key = alertController.textFields?[0].text
            self.finishMission()
        }))
        self.present(alertController, animated: true, completion: nil)
        
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
        
        let finishCondition = FinishMission(done: done!, key: key)
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
                if response.statusCode == 200 {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                            self.mercenaryVC?.getRewardHistory(closure: { (rewardHistory) in
                                self.mercenaryVC?.rewardList = rewardHistory.posts
                                self.mercenaryVC?.filterList = (self.mercenaryVC?.rewardList.filter { ($0.done == 1) })!
                                DispatchQueue.main.async {
                                    self.mercenaryVC?.rewardTable.reloadData()
                                }
                            })
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
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
