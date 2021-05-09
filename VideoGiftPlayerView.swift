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
    
    private var frameComposer: FrameComposer?
    
    public func play(baseVideo: URL, alphaVideo: URL) {
        frameComposer = FrameComposer(baseVideoURL: baseVideo, alphaVideoURL: alphaVideo, layer: layer as! CAMetalLayer)
    }
    
    public func configure() {
        backgroundColor = .clear
    }
    
}

protocol MetalLayer {
    func drawable() -> CAMetalDrawable?
}


// FIXME: iOS13以前のサポートさせる
@available(iOS 13.0, *)
extension CAMetalLayer: MetalLayer {
    func drawable() -> CAMetalDrawable? {
        return self.nextDrawable()
    }
}

class DefaultMetalLayer: MetalLayer {
    func drawable() -> CAMetalDrawable? {
        fatalError("dont use default metal layer")
    }
}
