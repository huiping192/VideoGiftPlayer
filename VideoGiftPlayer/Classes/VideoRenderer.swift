//
//  VideoProcessor.swift
//  VideoGiftPlayer
//
//  Created by Huiping Guo on 2021/04/17.
//

import Foundation
import AVFoundation
import MetalKit

/**
 metal 使って2つの動画frameを合成する
 */
internal final class VideoRenderer {
  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue
  private var textureCache: CVMetalTextureCache?
  
  private var pipelineState: MTLRenderPipelineState!
  private var fragmentFunctionName: String = "fragment_shader"
  private var vertexFunctionName: String = "vertex_shader"
  
  private var vertexBuffer: MTLBuffer?
  private var indexBuffer: MTLBuffer?
  
  var layer: MetalLayer?
  private let renderPassDescriptor = MTLRenderPassDescriptor()
  
  private let renderQueue = DispatchQueue(label: "com.huiping192.VideoGiftPlayer.RenderQueue")
  
  private let vertices: [float4] = [
    float4( -1.0, -1.0, 0, 1),
    float4(1.0, -1.0, 0, 1),
    float4(-1.0, 1.0, 0, 1),
    float4(1.0, 1.0, 0, 1)
  ]
  
  private let indices: [float2] = [
    float2(0, 1),
    float2(1, 1),
    float2(0, 0),
    float2(1, 0)
  ]
  
  private var vertexDescriptor: MTLVertexDescriptor {
    let vertexDescriptor = MTLVertexDescriptor()
    vertexDescriptor.attributes[0].format = .float4
    vertexDescriptor.attributes[0].offset = 0
    vertexDescriptor.attributes[0].bufferIndex = 0
    vertexDescriptor.attributes[1].format = .float2
    vertexDescriptor.attributes[1].offset = MemoryLayout<float4>.stride
    vertexDescriptor.attributes[1].bufferIndex = 0
    
    vertexDescriptor.layouts[0].stride = MemoryLayout<float4>.stride
    return vertexDescriptor
  }
  
  init() throws {
    self.device =  MTLCreateSystemDefaultDevice()!
    self.commandQueue = device.makeCommandQueue()!
    
    self.textureCache = CVMetalTextureCache.make(device: device)
    
    vertexBuffer = device.makeBuffer(bytes: vertices,
                                     length: vertices.count * MemoryLayout<float4>.size,
                                     options: [])
    indexBuffer = device.makeBuffer(bytes: indices,
                                    length: indices.count * MemoryLayout<float2>.size, options: [])
    
    self.pipelineState = try buildPipelineState(device: device)
  }
  
  private func buildPipelineState(device: MTLDevice) throws -> MTLRenderPipelineState {
    let url = Bundle(for: VideoRenderer.self).url(forResource: "default", withExtension: "metallib")!
    let library = try device.makeLibrary(URL: url)
    let vertexFunction = library.makeFunction(name: vertexFunctionName)
    let fragmentFunction = library.makeFunction(name: fragmentFunctionName)
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    pipelineDescriptor.vertexDescriptor = vertexDescriptor
    return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
  }
  
  func render(baseVideoFrame: CMSampleBuffer, alphaVideoFrame: CMSampleBuffer) {
    renderQueue.async {
      self.innerRender(baseVideoFrame: baseVideoFrame, alphaVideoFrame: alphaVideoFrame)
    }
  }
  
  private func innerRender(baseVideoFrame: CMSampleBuffer, alphaVideoFrame: CMSampleBuffer) {
    guard let baseImageBuffer = CMSampleBufferGetImageBuffer(baseVideoFrame), let alphaImageBuffer = CMSampleBufferGetImageBuffer(alphaVideoFrame) else { return }
    
    guard let yTexture = textureCache?.texture(imageBuffer: baseImageBuffer, pixelFormat: .r8Unorm, planeIndex: 0),
          let uvTexture = textureCache?.texture(imageBuffer: baseImageBuffer, pixelFormat: .rg8Unorm, planeIndex: 1),
          let alphaTexture = textureCache?.texture(imageBuffer: alphaImageBuffer, pixelFormat: .r8Unorm, planeIndex: 0) else { return }
    
    guard let drawable = layer?.drawable() else { return }
    guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
    
    guard let renderPipeline = pipelineState else { return }
    
    let renderPassDescriptor = MTLRenderPassDescriptor()
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture
    renderPassDescriptor.colorAttachments[0].loadAction = .clear
    
    let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
    
    renderEncoder.setRenderPipelineState(renderPipeline)
    
    // Vertex
    renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    renderEncoder.setVertexBuffer(indexBuffer, offset: 0, index: 1)
    
    // Texture
    renderEncoder.setFragmentTexture(yTexture, index: 0)
    renderEncoder.setFragmentTexture(uvTexture, index: 1)
    renderEncoder.setFragmentTexture(alphaTexture, index: 2)
    
    renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    
    renderEncoder.endEncoding()
    
    commandBuffer.present(drawable)
    
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
  }
  
  func clear() {
    renderQueue.async {
      guard let drawable = self.layer?.drawable() else { return }
      
      let renderDesc = MTLRenderPassDescriptor()
      renderDesc.colorAttachments[0].texture = drawable.texture
      renderDesc.colorAttachments[0].clearColor = MTLClearColorMake(0,0,0,0)
      renderDesc.colorAttachments[0].loadAction = .clear
      let commandBuffer = self.commandQueue.makeCommandBuffer()
      let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderDesc)
      renderEncoder?.endEncoding()
      commandBuffer?.present(drawable)
      
      commandBuffer?.commit()
      commandBuffer?.waitUntilCompleted()
    }
  }
}
