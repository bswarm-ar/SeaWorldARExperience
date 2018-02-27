//
//  AnimationViewController.swift
//  SeaworldARDemo
//
//  Created by ChristianBieniak on 9/1/18.
//  Copyright © 2018 Papercloud. All rights reserved.
//

import UIKit
import AVKit
import BswarmFramework

class DisplayAnimationViewController: UIViewController {
    
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var mediaDisplayButton: UIButton!
    
    var animationId: String!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.animationView.start(.ar)
        self.animationView.displayFromDefaultDirectory(animationId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.animationView.reset()
    }
    
    @IBAction func screenshotTouchedUpInside(_ sender: Any) {
        let img = self.animationView.screenshot()
        self.mediaDisplayButton.setImage(img, for: .normal)
    }
    
    @IBAction func recordVideoTouchUpInside(_ sender: Any) {
        if self.animationView.isRecording {
            self.animationView.stopRecording(completion: { (url) in
                let player = AVPlayer(url: url)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                DispatchQueue.main.async {
                    self.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                }
            })
        } else {
            try? self.animationView.startRecording()
        }
    }
}
