//
//  Utils.swift
//  VideoGiftPlayer
//
//  Created by Huiping Guo on 2021/05/10.
//

import Foundation


extension CVMetalTextureCache {
  static func make(device: MTLDevice) -> CVMetalTextureCache? {
    var textureCache: CVMetalTextureCache?
    CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)
    return textureCache
  }
  
  func texture(imageBuffer: CVImageBuffer, pixelFormat: MTLPixelFormat, planeIndex: Int = 0) -> MTLTexture?  {
    let width = CVPixelBufferGetWidthOfPlane(imageBuffer, planeIndex)
    let height = CVPixelBufferGetHeightOfPlane(imageBuffer, planeIndex)
    
    var imageTexture: CVMetalTexture?
    let result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self, imageBuffer, nil, pixelFormat, width, height, planeIndex, &imageTexture)
    guard let realImageTexture = imageTexture, result == kCVReturnSuccess else { return nil }
    return CVMetalTextureGetTexture(realImageTexture)
  }
}
