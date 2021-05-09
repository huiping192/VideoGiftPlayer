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
    
        let baseFileName = "base"
        let alphaFileName = "mask"
        
        copyFileIfNeeded(fileName: baseFileName)
        copyFileIfNeeded(fileName: alphaFileName)
        
        playerView = VideoGiftPlayerView()
        
        playerView.configure()
        view.addSubview(playerView)
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            playerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        view.backgroundColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let baseFileName = "base"
        let alphaFileName = "mask"
        
        let baseUrl = filePath(fileName: baseFileName)
        let alphaUrl = filePath(fileName: alphaFileName)
        
        playerView.play(baseVideo: baseUrl, alphaVideo: alphaUrl)
    }

}

