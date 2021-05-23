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
    
    func texture(imageBuffer: CVImageBuffer, pixelFormat: MTLPixelFormat) -> MTLTexture?  {
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        var imageTexture: CVMetalTexture?
        let result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self, imageBuffer, nil, pixelFormat, width, height, 0, &imageTexture)
        guard let realImageTexture = imageTexture, result == kCVReturnSuccess else { return nil }
        return CVMetalTextureGetTexture(realImageTexture)
    }
}
