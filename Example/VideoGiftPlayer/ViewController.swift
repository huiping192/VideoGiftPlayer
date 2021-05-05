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
    
    var videoSource: VideoSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        let baseFileName = "base"
        let alphaFileName = "mask"
        
        copyFileIfNeeded(fileName: baseFileName)
        copyFileIfNeeded(fileName: alphaFileName)
        
        let baseUrl = filePath(fileName: baseFileName)
        let alphaUrl = filePath(fileName: alphaFileName)
        
        videoSource = VideoSource(baseVideoURL: baseUrl, alphaVideoURL: alphaUrl)
        videoSource.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        videoSource.start()
    }

}

extension ViewController: VideoSourceDelegate {
    func videoSource(_ videoSource: VideoSource, didOutput sampleBuffer: (CMSampleBuffer,CMSampleBuffer)) {
    }

}

