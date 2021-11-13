//
//  MetalLayer.swift
//  VideoGiftPlayer
//
//  Created by Huiping Guo on 2021/05/10.
//

import Foundation
import MetalKit

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
