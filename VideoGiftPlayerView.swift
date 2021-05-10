//
//  VideoGiftPlayerView.swift
//  VideoGiftPlayer
//
//  Created by Huiping Guo on 2021/04/17.
//

import Foundation
import MetalKit

public class VideoGiftPlayerView: UIView {
    override public class var layerClass: AnyClass {
        return CAMetalLayer.self
    }
    
    private let frameComposer = FrameComposer()
    
    public func play(baseVideo: URL, alphaVideo: URL) {
        frameComposer.play(baseVideoURL: baseVideo, alphaVideoURL: alphaVideo)
    }
    
    private func configure() {
        let gpuLayer = self.layer as! CAMetalLayer
        frameComposer.configure(layer: gpuLayer)
        backgroundColor = .clear
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configure()
    }
    
}
