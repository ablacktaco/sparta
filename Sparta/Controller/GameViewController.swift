//
//  GameViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/27.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController {

    var spartaPlayer: AVAudioPlayer!
    var gunPlayer: AVAudioPlayer!
    var voicePlayer: AVAudioPlayer!
    
    var countDownTimer: Timer?
    var point = 0
    var bulletCount = 50
    
    var jesTimer: Timer?
    var charleenTimer: Timer?
    var louisTimer: Timer?
    var wangwangTimer: Timer?
    var oldFishTimer: Timer?
    var sproutsTimer: Timer?
    
    var userVC: UserViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = Bundle.main.url(forResource: "thisIsSparta", withExtension: ".mp3")
        do {
            spartaPlayer = try AVAudioPlayer(contentsOf: url!)
            spartaPlayer.play()
        } catch {
            print("Error:", error.localizedDescription)
        }
        
        setCountDownTimer()
        setMotion()
        
    }

    @IBOutlet var countDownTimeLabel: UILabel!
    @IBOutlet var bulletCountLabel: UILabel!
    @IBOutlet var pointLabel: UILabel!
    
    @IBOutlet var gameView: UIView!
    @IBOutlet var jes: UIImageView!
    @IBOutlet var charleen: UIImageView!
    @IBOutlet var louis: UIImageView!
    @IBOutlet var wangwang: UIImageView!
    @IBOutlet var oldFish: UIImageView!
    @IBOutlet var sprouts: UIImageView!
    
    @IBOutlet var center: UIImageView!
    
    @IBAction func upCenter(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            self.center.center.y -= 3
        }
    }
    @IBAction func leftCenter(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            self.center.center.x -= 3
        }
    }
    @IBAction func rightCenter(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            self.center.center.x += 3
        }
    }
    @IBAction func downCenter(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            self.center.center.y += 3
        }
    }
    
    @IBAction func tapToShot(_ sender: UIButton) {
        
        let url = Bundle.main.url(forResource: "gun", withExtension: ".mp3")
        do {
            spartaPlayer = try AVAudioPlayer(contentsOf: url!)
            spartaPlayer.play()
        } catch {
            print("Error:", error.localizedDescription)
        }
        
        bulletCount -= 1
        bulletCountLabel.text = "剩餘子彈: \(bulletCount) 顆"
        
        if sprouts.frame.contains(center.center) {
            if !sprouts.isHidden {
                timerInvalidate()
                countDownTimeLabel.text = "GAME OVER"
                point = 0
                pointLabel.text = "得分: \(point) 分"
                shotSproutsAlert()
                return
            }
        } else if oldFish.frame.contains(center.center) {
            if !oldFish.isHidden {
                point += 10
                pointLabel.text = "得分: \(point) 分"
            }
        } else if wangwang.frame.contains(center.center) {
            if !wangwang.isHidden {
                point -= 50
                if point < 0 {
                    point = 0
                }
                pointLabel.text = "得分: \(point) 分"
            }
        } else if louis.frame.contains(center.center) {
            if !louis.isHidden {
                point += 30
                pointLabel.text = "得分: \(point) 分"
            }
        } else if charleen.frame.contains(center.center) {
            if !charleen.isHidden {
                point += 50
                pointLabel.text = "得分: \(point) 分"
            }
        } else if jes.frame.contains(center.center) {
            if !jes.isHidden {
                point += 100
                pointLabel.text = "得分: \(point) 分"
            }
        }
        
        if bulletCount == 0 {
            timerInvalidate()
            outOfBulletAlert()
        }
        
    }
    
}

extension GameViewController {
    
    func setCountDownTimer() {
        var initialTime = 30
        
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            
            if initialTime % 7 == 0 || initialTime % 4 == 0 {
                let url = Bundle.main.url(forResource: "scream", withExtension: ".mp3")
                do {
                    self.spartaPlayer = try AVAudioPlayer(contentsOf: url!)
                    self.spartaPlayer.play()
                } catch {
                    print("Error:", error.localizedDescription)
                }
            }
            
            self.countDownTimeLabel.text = "剩餘時間： \(initialTime) 秒"
            if initialTime != 0 {
                initialTime -= 1
            } else {
                self.timerInvalidate()
                self.timeIsUpAlert()
            }
        }
    }
    
    func earnMoney() {
        
        let money = EarnMoney(earned: point)
        guard let uploadData = try? JSONEncoder().encode(money) else { return }
            
        let url = URL(string: "http://34.80.65.255/api/earn")!
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
                        self.userVC!.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    func timeIsUpAlert() {
        let alertController = UIAlertController(title: "Time's up", message: "You earned $\(point)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if self.point != 0 {
                self.earnMoney()
            } else {
                self.userVC!.dismiss(animated: true, completion: nil)
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func shotSproutsAlert() {
        let alertController = UIAlertController(title: "Do NOT shot sprouts 👿", message: "You earned $\(point)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "QQ", style: .default, handler: { (_) in
            self.userVC!.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func outOfBulletAlert() {
        let alertController = UIAlertController(title: "Out of bullet", message: "You earned $\(point)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if self.point != 0 {
                self.earnMoney()
            } else {
                self.userVC!.dismiss(animated: true, completion: nil)
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setMotion() {
        
        let rect = gameView.frame
        
        jesTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { (timer) in
            UIView.animate(withDuration: 0.5) {
                self.jes.isHidden = Bool.random()
                self.jes.center = CGPoint(x: CGFloat.random(in: 0...rect.width), y: CGFloat.random(in: 0...rect.height))
            }
        }
        
        charleenTimer = Timer.scheduledTimer(withTimeInterval: 1.7, repeats: true) { (timer) in
            UIView.animate(withDuration: 0.2) {
                self.charleen.isHidden = Bool.random()
                self.charleen.center = CGPoint(x: CGFloat.random(in: 0...rect.width), y: CGFloat.random(in: 0...rect.height))
            }
        }
        
        louisTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            UIView.animate(withDuration: 0.5) {
                self.louis.center = CGPoint(x: CGFloat.random(in: 0...rect.width), y: CGFloat.random(in: 0...rect.height))
            }
        }
        
        wangwangTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { (timer) in
            UIView.animate(withDuration: 4) {
                self.wangwang.center = CGPoint(x: CGFloat.random(in: 0...rect.width), y: CGFloat.random(in: 0...rect.height))
            }
        }
        
        oldFishTimer = Timer.scheduledTimer(withTimeInterval: 2.2, repeats: true) { (timer) in
            UIView.animate(withDuration: 0.2) {
                self.oldFish.center = CGPoint(x: CGFloat.random(in: 0...rect.width), y: CGFloat.random(in: 0...rect.height))
            }
        }
        
        sproutsTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { (timer) in
            UIView.animate(withDuration: 0.2) {
                self.sprouts.isHidden = Bool.random()
                self.sprouts.center = CGPoint(x: CGFloat.random(in: 0...rect.width), y: CGFloat.random(in: 0...rect.height))
            }
        }
        
    }
    
    func timerInvalidate() {
        countDownTimer?.invalidate()
        jesTimer?.invalidate()
        charleenTimer?.invalidate()
        louisTimer?.invalidate()
        wangwangTimer?.invalidate()
        oldFishTimer?.invalidate()
        sproutsTimer?.invalidate()
    }

    @IBAction func handleUpLongPress(_ sender: UILongPressGestureRecognizer) {
        
        sender.addTarget(self, action: #selector(upCenter(_:)))
        
    }
    
    @IBAction func handleDownLongPress(_ sender: UILongPressGestureRecognizer) {
        
        sender.addTarget(self, action: #selector(downCenter(_:)))
        
    }
    
    @IBAction func handleLeftLongPress(_ sender: UILongPressGestureRecognizer) {
        
        sender.addTarget(self, action: #selector(leftCenter(_:)))
        
    }
    
    @IBAction func handleRightLongPress(_ sender: UILongPressGestureRecognizer) {
        
        sender.addTarget(self, action: #selector(rightCenter(_:)))
        
    }
    
    @IBAction func handleShotLongPress(_ sender: UILongPressGestureRecognizer) {
        
        sender.addTarget(self, action: #selector(tapToShot(_:)))
        
    }
    
}
