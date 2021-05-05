//
//  VideoSource.swift
//  VideoGiftPlayer
//
//  Created by Huiping Guo on 2021/05/03.
//

import Foundation
import AVFoundation

//- captureOutput:didOutputSampleBuffer:fromConnection:


public protocol VideoSourceDelegate: class {
    func videoSource(_ videoSource: VideoSource, didOutput sampleBuffer: (CMSampleBuffer,CMSampleBuffer))
    
    // todo: frame drop delegate
}

public class VideoSource {
    
    private let baseVideoReader: VideoReader
    private let alphaVideoReader: VideoReader
    
    private let queue = DispatchQueue(label: "com.huiping192.VideoGiftPlayer.VideoSourceQueue")
    
    private var list: [(CMSampleBuffer,CMSampleBuffer)] = []
    
    private var displayLink: CADisplayLink!
    
    private var pause = true {
        didSet {
            displayLink.isPaused = pause
        }
    }
    
    public weak var delegate: VideoSourceDelegate?
    
    public init(baseVideoURL: URL, alphaVideoURL: URL) {
        baseVideoReader = VideoReader(videoURL: baseVideoURL)
        alphaVideoReader = VideoReader(videoURL: alphaVideoURL)
        
        // 事前に3frame読み込みする
        (0..<3).forEach({ _ in
            self.readNextData()
        })
        
        setupDisplayLink()
    }
    
    func setupDisplayLink() {
        let displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(ouput))
        displayLink?.isPaused = pause
        if #available(iOS 10.0, *) { //fixme: 動画framerateにする
            displayLink?.preferredFramesPerSecond = 30
        }
        displayLink?.add(to: .current,
                           forMode: .defaultRunLoopMode)
        self.displayLink = displayLink
    }
    
    
    public func start() {
        pause = false
    }
    
    public func stop() {
        pause = true
    }
        
    @objc func ouput() {
        readNextData()
        guard let data = list.first else { return }
        delegate?.videoSource(self, didOutput: data)
    }
    
    private func readNextData() {
        queue.async {
            guard let baseVideoFrame = self.baseVideoReader.read(), let alphaVideoFrame = self.alphaVideoReader.read() else { return }
            self.list.append((baseVideoFrame,alphaVideoFrame))
        }
    }
}
