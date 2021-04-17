//
//  FrameComposer.swift
//  VideoGiftPlayer
//
//  Created by Huiping Guo on 2021/04/17.
//

import Foundation

protocol FrameComposerDelegate {
    
}

class FrameComposer {
    
    private let baseVideoReader: VideoReader
    private let alphaVideoReader: VideoReader
    
    private let videoProcessor = VideoProcessor()
    
    init(baseVideoURL: URL, alphaVideoURL: URL) {
        baseVideoReader = VideoReader(videoURL: baseVideoURL)
        alphaVideoReader = VideoReader(videoURL: alphaVideoURL)
    }
    
    func read() {
        guard let baseVideoFrame = baseVideoReader.read(), let alphaVideoFrame = alphaVideoReader.read() else { return }
        
        videoProcessor.process(baseVideoFrame: baseVideoReader, alphaVideoFrame: alphaVideoFrame)
    }
}
