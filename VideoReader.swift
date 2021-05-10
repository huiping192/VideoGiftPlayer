//
//  VideoReader.swift
//  VideoGiftPlayer
//
//  Created by Huiping Guo on 2021/04/17.
//

import Foundation
import AVFoundation

/**
 動画reader
 */
class VideoReader {
    private let videoURL: URL
    
    private let asset: AVURLAsset
    private var reader: AVAssetReader
    private var output: AVAssetReaderTrackOutput
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        self.asset = AVURLAsset(url: videoURL)
        
        reader = try! AVAssetReader(asset: asset)
        
        let attrs = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                     kCVPixelBufferMetalCompatibilityKey as String: true] as [String : Any]
        output = AVAssetReaderTrackOutput(track: asset.tracks(withMediaType: AVMediaType.video)[0], outputSettings: attrs)
        if reader.canAdd(output) {
            reader.add(output)
        }
        
        // offでパフォーマンス改善
        output.alwaysCopiesSampleData = false
        
        reader.startReading()
    }
    
    func read() -> CMSampleBuffer? {
        return output.copyNextSampleBuffer()
    }
    
}
