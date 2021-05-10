//
//  VideoSource.swift
//  VideoGiftPlayer
//
//  Created by Huiping Guo on 2021/05/03.
//

import Foundation
import AVFoundation

internal protocol VideoSourceDelegate: class {
    // output two videos each frames
    func videoSource(_ videoSource: VideoSource, didOutput sampleBuffer: (CMSampleBuffer,CMSampleBuffer))
    
    // output completed
    func videoSource(didCompleted videoSource: VideoSource)
    
    
    // todo: frame drop delegate
}


// FIXME: thread safe
internal final class VideoSource {
    
    private let baseVideoReader: VideoReader
    private let alphaVideoReader: VideoReader
    
    private let queue = DispatchQueue(label: "com.huiping192.VideoGiftPlayer.VideoSourceQueue")
    
    private var list: [(CMSampleBuffer,CMSampleBuffer)] = []
    
    private var displayLink: CADisplayLink?
    
    private var pause = true {
        didSet {
            displayLink?.isPaused = pause
        }
    }
    
    internal weak var delegate: VideoSourceDelegate?
    
    internal init(baseVideoURL: URL, alphaVideoURL: URL) {
        baseVideoReader = VideoReader(videoURL: baseVideoURL)
        alphaVideoReader = VideoReader(videoURL: alphaVideoURL)
        
        baseVideoReader.delegate = self
        alphaVideoReader.delegate = self
        
        setupDisplayLink()
        preloadFrames()
    }
    
    private func preloadFrames() {
        // 事前に3frame読み込みする
        (0..<3).forEach({ _ in
            self.readNextData()
        })
    }
    
    private func setupDisplayLink() {
        let displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(ouput))
        displayLink?.isPaused = pause
        
        //動画framerateにする
        displayLink?.preferredFramesPerSecond = Int(baseVideoReader.nominalFrameRate)
        
        displayLink?.add(to: .current, forMode: .defaultRunLoopMode)
        self.displayLink = displayLink
    }
    
    internal func start() {
        pause = false
    }
    
    internal func stop() {
        pause = true
    }
        
    @objc private func ouput() {
        autoreleasepool {
            readNextData()
            
            guard !list.isEmpty else { return }
            let data = list.removeFirst()
            delegate?.videoSource(self, didOutput: data)
        }
        
    }
    
    private func readNextData() {
        queue.async {
            guard let baseVideoFrame = self.baseVideoReader.read(), let alphaVideoFrame = self.alphaVideoReader.read() else { return }
            self.list.append((baseVideoFrame,alphaVideoFrame))
        }
    }
}


extension VideoSource: VideoReaderDelegate {
    func videoReader(_ videoReader: VideoReader, didChange status: VideoReader.Status) {
        if status == .completed {
            self.pause = true
            delegate?.videoSource(didCompleted: self)
        }
    }
}
