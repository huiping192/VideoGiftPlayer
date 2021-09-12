//
//  compose.metal
//  VideoGiftPlayer
//
//  Created by Huiping Guo on 2021/04/18.
//

#include <metal_stdlib>
using namespace metal;

struct ColorInOut {
  float4 position [[ position ]];
  float2 texCoords;
};

vertex ColorInOut vertex_shader(const device float4 *position [[ buffer(0) ]],
                               const device float2 *texCoords [[ buffer(1) ]],
                               uint    vid      [[ vertex_id ]]) {
  ColorInOut out;
  out.position = position[vid];
  out.texCoords = texCoords[vid];
  return out;
}

fragment half4 fragment_shader(ColorInOut in [[ stage_in ]],
                               texture2d<half> yTexture [[ texture(0) ]],
                               texture2d<half> uvTexture [[ texture(1) ]],
                               texture2d<half> alphaTexture [[ texture(2) ]]) {
  constexpr sampler colorSampler;
  
  const half4x4 ycbcrToRGBTransform = half4x4(
                                              half4(+1.0000f, +1.0000f, +1.0000f, +0.0000f),
                                              half4(+0.0000f, -0.3441f, +1.7720f, +0.0000f),
                                              half4(+1.4020f, -0.7141f, +0.0000f, +0.0000f),
                                              half4(-0.7010f, +0.5291f, -0.8860f, +1.0000f)
                                              );
  
  half4 ycbcr = half4(yTexture.sample(colorSampler, in.texCoords).r,
                        uvTexture.sample(colorSampler, in.texCoords).rg, 1.0);
  
  half4 rgb = ycbcrToRGBTransform * ycbcr;
  half4 alphaColor = alphaTexture.sample(colorSampler, in.texCoords);
  return half4(rgb.r, rgb.g, rgb.b, alphaColor.r);
}
