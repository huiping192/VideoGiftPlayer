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
class VideoRenderer {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private var textureCache: CVMetalTextureCache?
    
    var pipelineState: MTLRenderPipelineState!
    var fragmentFunctionName: String = "fragment_shader"
    var vertexFunctionName: String = "vertex_shader"
    
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    
    var layer: MetalLayer?
    private let renderPassDescriptor = MTLRenderPassDescriptor()
    
    private let renderQueue = DispatchQueue(label: "com.huiping192.VideoGiftPlayer.RenderQueue")

    let vertices: [float4] = [
        float4( -1.0, -1.0, 0, 1),
        float4(1.0, -1.0, 0, 1),
        float4(-1.0, 1.0, 0, 1),
        float4(1.0, 1.0, 0, 1)
    ]
    
    let indices: [float2] = [
        float2(0, 1),
        float2(1, 1),
        float2(0, 0),
        float2(1, 0)
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
                                         length: vertices.count * MemoryLayout<float4>.size,
                                         options: [])
        indexBuffer = device.makeBuffer(bytes: indices,
                                        length: indices.count * MemoryLayout<float2>.size, options: [])
        
        self.pipelineState = buildPipelineState(device: device)
    }
    
    func buildPipelineState(device: MTLDevice) -> MTLRenderPipelineState {
        let url = Bundle(for: VideoRenderer.self).url(forResource: "default", withExtension: "metallib")!
        let library = try? device.makeLibrary(URL: url)
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
    
     
    func texture(imageBuffer: CVImageBuffer) -> MTLTexture? {
        guard let textureCache = textureCache else { return nil }
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        var imageTexture: CVMetalTexture?
        let result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, imageBuffer, nil, .bgra8Unorm, width, height, 0, &imageTexture)
        guard let realImageTexture = imageTexture, result == kCVReturnSuccess else { return nil }
        return CVMetalTextureGetTexture(realImageTexture)
    }
    
    func render(baseVideoFrame: CMSampleBuffer, alphaVideoFrame: CMSampleBuffer) {
        renderQueue.async {
            self.innerRender(baseVideoFrame: baseVideoFrame, alphaVideoFrame: alphaVideoFrame)
        }
    }
    func innerRender(baseVideoFrame: CMSampleBuffer, alphaVideoFrame: CMSampleBuffer) {
        guard let baseImageBuffer = CMSampleBufferGetImageBuffer(baseVideoFrame), let alphaImageBuffer = CMSampleBufferGetImageBuffer(alphaVideoFrame) else { return }
        
        guard let baseTexture = texture(imageBuffer: baseImageBuffer), let alphaTexture = texture(imageBuffer: alphaImageBuffer) else { return }
        
        guard let drawable = layer?.drawable() else { return }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }

        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear

        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!

        guard let renderPipeline = pipelineState else {fatalError()}
        renderEncoder.setRenderPipelineState(renderPipeline)
        
        // Vertex
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(indexBuffer, offset: 0, index: 1)
        
        // Texture
        renderEncoder.setFragmentTexture(baseTexture, index: 0)
        renderEncoder.setFragmentTexture(alphaTexture, index: 1)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
