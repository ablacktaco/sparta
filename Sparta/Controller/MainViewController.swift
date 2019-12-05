//
//  MainViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/25.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {

    var spartaPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spartaGifView.loadGif(name: "sparta")
        
        let url = Bundle.main.url(forResource: "background", withExtension: ".mp3")
        do {
            spartaPlayer = try AVAudioPlayer(contentsOf: url!)
            spartaPlayer.play()
        } catch {
            print("Error:", error.localizedDescription)
        }
    }
    
    @IBOutlet var mainButtons: [UIButton]! {
        didSet {
            for button in mainButtons {
                setViewBorder(view: button, configSetting: .mainButton)
            }
        }
    }
    @IBOutlet var spartaGifView: UIImageView!
    
    @IBAction func tapToStopMusic(_ sender: UIButton) {
        spartaPlayer.stop()
    }
    
}
