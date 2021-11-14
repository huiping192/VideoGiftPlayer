//
//  VideoSource.swift
//  VideoGiftPlayer
//
//  Created by Huiping Guo on 2021/05/03.
//

import Foundation
import AVFoundation

internal protocol VideoSourceDelegate: AnyObject {
  // output two videos each frames
  func videoSource(_ videoSource: VideoSource, didMP4Output sampleBuffer: (CMSampleBuffer,CMSampleBuffer))
  
  // output one hevc frame
  func videoSource(_ videoSource: VideoSource, didHEVCOutput sampleBuffer: CMSampleBuffer)

  // output completed
  func videoSource(didCompleted videoSource: VideoSource)
}

internal protocol VideoSource {
  
}

internal class MP4VideoSource: VideoSource {
  
  private let baseVideoReader: VideoReader
  private let alphaVideoReader: VideoReader
    
  private let readerQueue = DispatchQueue(label: "com.huiping192.VideoGiftPlayer.VideoSource.ReaderQueue")
  
  private let dataQueue = DispatchQueue(label: "com.huiping192.VideoGiftPlayer.VideoSource.DataQueue")
  
  private var list: [(CMSampleBuffer,CMSampleBuffer)] = []
  
  private var displayLink: CADisplayLink?
  
  private var audioPlayer: AVAudioPlayer?
  
  private var pause = true {
    didSet {
      displayLink?.isPaused = pause
      if pause {
        audioPlayer?.pause()
      } else {
        audioPlayer?.play()
      }
    }
  }
  
  internal weak var delegate: VideoSourceDelegate?
  
  internal init(baseVideoURL: URL, alphaVideoURL: URL) throws {
    baseVideoReader = try VideoReader(videoURL: baseVideoURL)
    alphaVideoReader = try VideoReader(videoURL: alphaVideoURL)
    
    baseVideoReader.delegate = self
    alphaVideoReader.delegate = self
    
    setupDisplayLink()
    setupAudioPlayerIfNeeded()

    preloadFrames()
  }

  private func preloadFrames() {
    // 事前に3frame読み込みする
    (0..<3).forEach({ _ in
      self.readNextData()
    })
  }
  
  private func setupDisplayLink() {
    let displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(ouput))
    displayLink?.isPaused = pause
    
    //動画framerateにする
    displayLink?.preferredFramesPerSecond = Int(baseVideoReader.nominalFrameRate)
    
    displayLink?.add(to: .current, forMode: .default)
    self.displayLink = displayLink
  }
  
  private func setupAudioPlayerIfNeeded() {
    if baseVideoReader.hasAudio {
      audioPlayer = try? AVAudioPlayer(contentsOf: baseVideoReader.videoURL)
      return
    }
    
    if alphaVideoReader.hasAudio {
      audioPlayer = try? AVAudioPlayer(contentsOf: alphaVideoReader.videoURL)
      return
    }
  }
  
  internal func start() {
    pause = false
  }
  
  internal func stop() {
    pause = true
  }
  
  @objc private func ouput() {
    autoreleasepool {
      readNextData()
      
      dataQueue.async {
        guard !self.list.isEmpty else { return }
        let data = self.list.removeFirst()
        self.delegate?.videoSource(self, didMP4Output: data)
      }
    }
    
  }
  
  private func readNextData() {
    readerQueue.async {
      guard let baseVideoFrame = self.baseVideoReader.read(), let alphaVideoFrame = self.alphaVideoReader.read() else { return }
      self.dataQueue.async {
        self.list.append((baseVideoFrame,alphaVideoFrame))
      }
    }
  }
}

internal class HEVCVideoSource: VideoSource {
    
  private let hevcVideoReader: VideoReader
  
  private let readerQueue = DispatchQueue(label: "com.huiping192.VideoGiftPlayer.VideoSource.ReaderQueue")
  
  private let dataQueue = DispatchQueue(label: "com.huiping192.VideoGiftPlayer.VideoSource.DataQueue")
  
  private var list: [CMSampleBuffer] = []
  
  private var displayLink: CADisplayLink?
  
  private var audioPlayer: AVAudioPlayer?
  
  private var pause = true {
    didSet {
      displayLink?.isPaused = pause
      if pause {
        audioPlayer?.pause()
      } else {
        audioPlayer?.play()
      }
    }
  }
  
  internal weak var delegate: VideoSourceDelegate?
  
  internal init(hevcURL: URL) throws {
    hevcVideoReader = try VideoReader(videoURL: hevcURL)
    
    hevcVideoReader.delegate = self
    
    setupDisplayLink()
    setupAudioPlayerIfNeeded()

    preloadFrames()
  }
  
  private func preloadFrames() {
    // 事前に3frame読み込みする
    (0..<3).forEach({ _ in
      self.readNextData()
    })
  }
  
  private func setupDisplayLink() {
    let displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(ouput))
    displayLink?.isPaused = pause
    
    //動画framerateにする
    displayLink?.preferredFramesPerSecond = Int(hevcVideoReader.nominalFrameRate)
    
    displayLink?.add(to: .current, forMode: .default)
    self.displayLink = displayLink
  }
  
  private func setupAudioPlayerIfNeeded() {
    if hevcVideoReader.hasAudio {
      audioPlayer = try? AVAudioPlayer(contentsOf: hevcVideoReader.videoURL)
      return
    }

  }
  
  internal func start() {
    pause = false
  }
  
  internal func stop() {
    pause = true
  }
  
  @objc private func ouput() {
    autoreleasepool {
      readNextData()
      
      dataQueue.async {
        guard !self.list.isEmpty else { return }
        let data = self.list.removeFirst()
        self.delegate?.videoSource(self, didHEVCOutput: data)
      }
    }
    
  }
  
  private func readNextData() {
    readerQueue.async {
      guard let baseVideoFrame = self.hevcVideoReader.read() else { return }
      self.dataQueue.async {
        self.list.append(baseVideoFrame)
      }
    }
  }
}

extension MP4VideoSource: VideoReaderDelegate {
  func videoReader(_ videoReader: VideoReader, didChange status: VideoReader.Status) {
    if status == .completed {
      self.pause = true
      delegate?.videoSource(didCompleted: self)
    }
  }
}


extension HEVCVideoSource: VideoReaderDelegate {
  func videoReader(_ videoReader: VideoReader, didChange status: VideoReader.Status) {
    if status == .completed {
      self.pause = true
      delegate?.videoSource(didCompleted: self)
    }
  }
}

