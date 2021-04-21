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
class VideoProcessor {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private var textureCache: CVMetalTextureCache?
    
    var pipelineState: MTLRenderPipelineState!
    var fragmentFunctionName: String = "fragment_shader"
    var vertexFunctionName: String = "vertex_shader"
    
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    
    var view: MTKView?
    private let renderPassDescriptor = MTLRenderPassDescriptor()

    
    let vertices: [float4] = [
        float4(-1.0, -1.0, 0, 1),
        float4(1.0, -1.0, 0, 1),
        float4(-1.0, 1.0, 0, 1),
        float4(1.0, 1.0, 0, 1),
    ]
    
    let indices: [UInt16] = [
          0, 1,
          1, 1,
          0, 0,
          1, 0
        ]
    
    var vertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<float3>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<float4>.stride
        return vertexDescriptor
    }
    
    init() {
        
        self.device =  MTLCreateSystemDefaultDevice()!
        self.commandQueue = device.makeCommandQueue()!
        
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)

        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: vertices.count * MemoryLayout<float4>.stride,
                                         options: [])
        indexBuffer = device.makeBuffer(bytes: indices,
                                        length: indices.count * MemoryLayout<UInt16>.size, options: [])
    }
    
    func buildPipelineState(device: MTLDevice) -> MTLRenderPipelineState {
        let library = device.makeDefaultLibrary()
        let vertexFunction =
            library?.makeFunction(name: vertexFunctionName)
        let fragmentFunction =
                library?.makeFunction(name: fragmentFunctionName)
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        let pipelineState: MTLRenderPipelineState
        do {
            pipelineState = try
                device.makeRenderPipelineState(descriptor: pipelineDescriptor) } catch let error as NSError {
                    fatalError("error: \(error.localizedDescription)") }
        return pipelineState
    }
    
    func process(baseVideoFrame: CMSampleBuffer, alphaVideoFrame: CMSampleBuffer) {
        guard let drawable = view?.currentDrawable else {return}
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {fatalError()}

        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!

        guard let renderPipeline = pipelineState else {fatalError()}
        renderEncoder.setRenderPipelineState(renderPipeline)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)

        // エンコード完了
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        
        commandBuffer.commit()
        
        commandBuffer.waitUntilCompleted()
    }
}
