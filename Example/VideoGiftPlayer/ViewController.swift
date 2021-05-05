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
        
        guard let baseUrlString = Bundle.main.path(forResource: "base", ofType: "mp4"),
              let alphaUrlString = Bundle.main.path(forResource: "mask", ofType: "mp4") else {
            return
        }
        
        let baseUrl = URL(string: baseUrlString)!
        let alphaUrl = URL(string: alphaUrlString)!

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
        let a = 0
    }

}

