//
//  ViewController.swift
//  VideoGiftPlayer
//
//  Created by huiping_guo on 04/14/2021.
//  Copyright (c) 2021 huiping_guo. All rights reserved.
//

import UIKit
import VideoGiftPlayer
import AVFoundation

class ViewController: UIViewController {
  
  var playerView: VideoGiftPlayerView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    playerView = VideoGiftPlayerView()
    view.addSubview(playerView)
    
    playerView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      playerView.leftAnchor.constraint(equalTo: view.leftAnchor),
      playerView.rightAnchor.constraint(equalTo: view.rightAnchor),
      playerView.topAnchor.constraint(equalTo: view.topAnchor),
      playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
    view.backgroundColor = UIColor.yellow
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
//    playMP4()
    
    playHEVC()
  }
  
  private func playMP4() {
    let baseUrl = Bundle.main.url(forResource: "base", withExtension: "mp4")!
    let alphaUrl = Bundle.main.url(forResource: "mask", withExtension: "mp4")!
    
    try? playerView.play(baseVideo: baseUrl, alphaVideo: alphaUrl)
  }
  
  private func playHEVC() {
    let hevcURL = Bundle.main.url(forResource: "hevc", withExtension: "mov")!
    
    try? playerView.play(hevcVideo: hevcURL)
  }
  
}

