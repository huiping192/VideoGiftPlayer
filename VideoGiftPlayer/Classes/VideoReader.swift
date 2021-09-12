//
//  VideoReader.swift
//  VideoGiftPlayer
//
//  Created by Huiping Guo on 2021/04/17.
//

import Foundation
import AVFoundation

protocol VideoReaderDelegate: class {
    func videoReader(_ videoReader: VideoReader, didChange status: VideoReader.Status)
}
/**
 動画reader
 */
internal final class VideoReader {
    private let videoURL: URL
    
    private let asset: AVURLAsset
    private var reader: AVAssetReader
    private var output: AVAssetReaderTrackOutput
    
    private(set) var status: Status = .unknown {
        didSet {
            delegate?.videoReader(self, didChange: status)
        }
    }
    
    let nominalFrameRate: Float
    
    weak var delegate: VideoReaderDelegate?
    
    enum Status: String {
        case unknown
        case reading
        case completed
        case failed
        case cancelled
    }
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        self.asset = AVURLAsset(url: videoURL)
        
        reader = try! AVAssetReader(asset: asset)
        
        let attrs = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
                     kCVPixelBufferMetalCompatibilityKey as String: true] as [String : Any]
        
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first!
        output = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: attrs)
        if reader.canAdd(output) {
            reader.add(output)
        }
        
        nominalFrameRate = videoTrack.nominalFrameRate
        
        // offでパフォーマンス改善
        output.alwaysCopiesSampleData = false
        
        reader.startReading()
        status = .reading
    }
    
    func read() -> CMSampleBuffer? {
        let buffer = output.copyNextSampleBuffer()
        updateStatus()
        return buffer
    }
    
    private func updateStatus() {
        switch reader.status {
        case .unknown:
            status = .unknown
        case .cancelled:
            status = .cancelled
        case .completed:
            status = .completed
        case .failed:
            status = .failed
        case .reading:
            status = .reading
        }
    }
    
}
