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
float2 acceleration;
float mass;

};

struct GCenter{

float2 position;
float mass;
float g;
int exists;

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
mdistance = constrain(mdistance,1,10);

force = normalize(float2(forceX,forceY));

strenght = (gravity.g * gravity.mass * particle.mass) / (mdistance);

force = force * float2(strenght,strenght);

return force;


}


kernel void clear_pass_func(texture2d<half, access::write> tex [[ texture(0) ]], uint2 id [[ thread_position_in_grid ]]){
tex.write(half4(0), id);
}


kernel void draw_Dots_Func(device Particle *particles [[buffer(0)]], texture2d<half,access::write> tex [[texture(0)]], uint id [[ thread_position_in_grid ]], device GCenter *gravity [[buffer(1)]]){


Particle particle;
particle = particles[id];

float2 position = particle.position;
float2 velocity = particle.velocity;
half4 color = half4(particle.color.r, particle.color.g, particle.color.b, 1);



if (gravity->exists == 1) {

// applying force
float2 force = calculateAtracttion(particle,*gravity);
float2 value = force / particle.mass;
particle.acceleration += value;

}





//update
particle.velocity = particle.velocity + particle.acceleration;
particle.position = particle.position + particle.velocity;
particle.acceleration = (particle.acceleration - 2) * 0;
//checking edges
if(particle.position.x > 1600) {
    particle.position.x = 1600;
} else if (particle.position.x < 0) {
        particle.position.x = 0;
}
if(particle.position.y > 1600) {
    particle.position.y = 1600;
} else if (particle.position.y < 0) {
        particle.position.y = 0;

}






particles[id] = particle;

uint2 texturePosition = uint2(position.x, position.y);
tex.write(color, texturePosition);


}



"""
}
