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
  private let renderer: VideoRenderer
  private var source: VideoSource?
  
  init() throws {
    renderer = try VideoRenderer()
  }
  
  func configure(layer: MetalLayer) {
    renderer.layer = layer
  }
  
  func play(baseVideoURL: URL, alphaVideoURL: URL) throws {
    let source = try MP4VideoSource(baseVideoURL: baseVideoURL, alphaVideoURL: alphaVideoURL)
    source.delegate = self
    source.start()
    
    self.source = source
  }
  
  func play(hevcURL: URL) throws {
    let source = try HEVCVideoSource(hevcURL: hevcURL)
    source.delegate = self
    source.start()
    
    self.source = source
  }
}

extension FrameComposer: VideoSourceDelegate {
  func videoSource(_ videoSource: VideoSource, didHEVCOutput sampleBuffer: CMSampleBuffer) {
    renderer.renderHEVC(hevcFrame: sampleBuffer)
  }
  
  func videoSource(_ videoSource: VideoSource, didMP4Output sampleBuffer: (CMSampleBuffer,CMSampleBuffer)) {
    renderer.render(baseVideoFrame: sampleBuffer.0, alphaVideoFrame: sampleBuffer.1)
  }
  
  func videoSource(didCompleted videoSource: VideoSource) {
    renderer.clear()
  }
}
