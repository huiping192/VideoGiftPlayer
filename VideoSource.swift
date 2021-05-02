//
//  VideoSource.swift
//  VideoGiftPlayer
//
//  Created by Huiping Guo on 2021/05/03.
//

import Foundation
import AVFoundation

//- captureOutput:didOutputSampleBuffer:fromConnection:


protocol VideoSourceDelegate {
    func videoSource(_ videoSource: VideoSource, didOutput sampleBuffer: (CMSampleBuffer,CMSampleBuffer))
}

class VideoSource {
    
    private let baseVideoReader: VideoReader
    private let alphaVideoReader: VideoReader
    
    private let queue = DispatchQueue(label: "com.huiping192.VideoGiftPlayer.VideoSourceQueue")
    
    private var list: [(CMSampleBuffer,CMSampleBuffer)] = []
    
    init(baseVideoURL: URL, alphaVideoURL: URL) {
        baseVideoReader = VideoReader(videoURL: baseVideoURL)
        alphaVideoReader = VideoReader(videoURL: alphaVideoURL)
        
        // 事前に3frame読み込みする
        (0..<3).forEach({ _ in
            self._read()
        })
    }
    
    func get() -> (CMSampleBuffer,CMSampleBuffer)? {
        return list.first
    }
    
    private func _read() {
        queue.async {
            guard let baseVideoFrame = self.baseVideoReader.read(), let alphaVideoFrame = self.alphaVideoReader.read() else { return }
            self.list.append((baseVideoFrame,alphaVideoFrame))
        }
    }
}
