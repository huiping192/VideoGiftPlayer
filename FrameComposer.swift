//
//  FrameComposer.swift
//  VideoGiftPlayer
//
//  Created by Huiping Guo on 2021/04/17.
//

import Foundation
import AVFoundation

// FIXME: いい名前に変える
class FrameComposer {
    
    private let renderer = VideoRenderer()
    private let source: VideoSource
    
    init(baseVideoURL: URL, alphaVideoURL: URL) {
        source = VideoSource(baseVideoURL: baseVideoURL, alphaVideoURL: alphaVideoURL)
    }
}

extension FrameComposer: VideoSourceDelegate {
    func videoSource(_ videoSource: VideoSource, didOutput sampleBuffer: (CMSampleBuffer,CMSampleBuffer)) {
        renderer.render(baseVideoFrame: sampleBuffer.0, alphaVideoFrame: sampleBuffer.1)
    }
}
