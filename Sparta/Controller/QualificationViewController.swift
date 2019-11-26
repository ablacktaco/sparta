//
//  QualificationViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/25.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class QualificationViewController: UIViewController {
    
    var regiVC: RegisterViewController?
    var question = [Int]()
    var userInput = [Int]()
    var countDownTimer: Timer?
    var count = 3
    var time = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swordImageView.isHidden = true
        shieldImageView.isHidden = true
        setCountDownTime()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        makeQuestions(count)
        showQuestion(count, time: time)
    }
    
    @IBOutlet var countDownLabel: UILabel!
    @IBOutlet var swordImageView: UIImageView!
    @IBOutlet var shieldImageView: UIImageView!
    @IBOutlet var answerButtons: [UIButton]!
    
    @IBAction func swordButton(_ sender: UIButton) {
        userInput.append(0)
        checkAnswer()
    }
    @IBAction func shieldButton(_ sender: UIButton) {
        userInput.append(1)
        checkAnswer()
    }
}

extension QualificationViewController {
    
    func setCountDownTime() {
        var initialTime = 20
        
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.countDownLabel.text = "剩餘時間： \(initialTime) 秒"
            if initialTime != 0 {
                initialTime -= 1
            } else {
                timer.invalidate()
                self.failedAlert()
            }
        }
    }
    
    func makeQuestions(_ count: Int) {
        question = []
        userInput = []
        for _ in 0..<count {
            question.append(Int.random(in: 0...1))
        }
    }
    
    func showQuestion(_ count: Int, time: Double) {
        var index = 0
        for button in answerButtons {
            button.isEnabled = false
        }
        Timer.scheduledTimer(withTimeInterval: time, repeats: true) { (timer) in
            if index < count * 2 {
                self.swordImageView.isHidden = true
                self.shieldImageView.isHidden = true
                guard index.isMultiple(of: 2) else { return index += 1 }
                if self.question[index / 2] == 0 {
                    self.swordImageView.isHidden = false
                } else {
                    self.shieldImageView.isHidden = false
                }
                index += 1
            } else {
                timer.invalidate()
                for button in self.answerButtons {
                    button.isEnabled = true
                }
            }
        }
    }
    
    fileprivate func checkAnswer() {
        if userInput.count == count {
            if userInput == question {
                count += 2
                time -= 0.1
                if count <= 7 {
                    makeQuestions(count)
                    showQuestion(count, time: time)
                } else {
                    successfulAlert()
                }
            } else {
                failedAlert()
            }
        }
    }
    
    fileprivate func successfulAlert() {
        countDownTimer?.invalidate()
        let alertController = UIAlertController(title: "Success", message: "Congrate for you to be a mercenary", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.dismiss(animated: true) {
                self.regiVC?.postRegisterData()
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func failedAlert() {
        countDownTimer?.invalidate()
        let alertController = UIAlertController(title: "Fail", message: "Where does your self-confidence come from?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Register in a mortal", style: .default, handler: { (_) in
            self.regiVC?.role.selectedSegmentIndex = 0
            self.dismiss(animated: true) {
                self.regiVC?.postRegisterData()
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}
