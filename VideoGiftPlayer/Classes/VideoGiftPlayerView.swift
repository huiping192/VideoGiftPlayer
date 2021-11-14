//
//  VideoGiftPlayerView.swift
//  VideoGiftPlayer
//
//  Created by Huiping Guo on 2021/04/17.
//

import Foundation
import MetalKit
import AVFoundation

public class VideoGiftPlayerView: UIView {
  override public class var layerClass: AnyClass {
    return CAMetalLayer.self
  }
  
  private var frameComposer: FrameComposer?
  
  private var configued: Bool = false
  
  public func play(baseVideo: URL, alphaVideo: URL) throws {
    if !configued {
      configued = true
      try configure()
    }
    
    try frameComposer?.play(baseVideoURL: baseVideo, alphaVideoURL: alphaVideo)
  }
  
  public func play(hevcVideo: URL) throws {
    if !configued {
      configued = true
      try configure()
    }
    
    try frameComposer?.play(hevcURL: hevcVideo)
  }
  
  private func configure() throws {
    frameComposer = try FrameComposer()
    
    let gpuLayer = self.layer as! CAMetalLayer
    frameComposer?.configure(layer: gpuLayer)
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .clear
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    backgroundColor = .clear
  }
  
}
