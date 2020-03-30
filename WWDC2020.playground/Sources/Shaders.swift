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
float mass;

};

struct GCenter{

float2 position;
float mass;
float g;

};


float constrain(float v1, float v2, float v3){

if (v1 >= v3) {
    return v3;
} else if (v1 <= v2){
        return v2;
} else {
    return v1;
}
return 1.0;

}


float2 calculateAtracttion(Particle particle, GCenter gravity){

float forceX, forceY;
float2 force;
float sum;
float mdistance;
float strenght;

forceX = gravity.position.x - particle.position.x;
forceY = gravity.position.y - particle.position.y;

sum = (forceX * forceX) + (forceY * forceY);

mdistance = sqrt(sum);
mdistance = constrain(mdistance,10,50);

force = normalize(float2(forceX,forceY));

strenght = (gravity.g * gravity.mass * particle.mass) / (mdistance);

force = force * float2(strenght,strenght);

return force;


}


kernel void clear_pass_func(texture2d<half, access::write> tex [[ texture(0) ]], uint2 id [[ thread_position_in_grid ]]){
tex.write(half4(0), id);
}


kernel void draw_Dots_Func(device Particle *particles [[buffer(0)]], texture2d<half,access::write> tex [[texture(0)]], uint id [[ thread_position_in_grid ]], device GCenter *gCenter [[buffer(1)]]){


Particle particle;
particle = particles[id];

float2 position = particle.position;
float2 velocity = particle.velocity;
half4 color = half4(particle.color.r, particle.color.g, particle.color.b, 1);

//position.x = gCenter->position.x;


uint2 texturePosition = uint2(position.x, position.y);
tex.write(color, texturePosition);


}



"""
}
