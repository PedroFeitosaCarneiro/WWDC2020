import Foundation
import MetalKit


public class Shaders {
    
static public let shader_Vertex_Function =
"""
#include <metal_stdlib>
using namespace metal;


struct Particle {

float4 color;
float2 position;
float2 velocity;

};

struct GCenter{

float2 position;

};


kernel void clear_pass_func(texture2d<half, access::write> tex [[ texture(0) ]], uint2 id [[ thread_position_in_grid ]]){
tex.write(half4(0), id);
}


kernel void draw_Dots_Func(device Particle *particles [[buffer(0)]], texture2d<half,access::write> tex [[texture(0)]], uint id [[ thread_position_in_grid ]], device GCenter *gCenter [[buffer(1)]]){


Particle particle;
particle = particles[id];

float2 position = particle.position;
float2 velocity = particle.velocity;
half4 color = half4(particle.color.r, particle.color.g, particle.color.b, 1);

position.x = gCenter->position.x;


uint2 texturePosition = uint2(position.x, position.y);
tex.write(color, texturePosition);


}



"""
}
