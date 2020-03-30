import Foundation
import UIKit
import MetalKit


struct Particle {
    var color : float4
    var position: float2
    var velocity: float2
    var mass : Float
}

struct GCenter{
    var position : float2
    var mass : Float
    var g : Float
}


public class MainView : MTKView {
    
    var commandQueue : MTLCommandQueue!
    var clearPass : MTLComputePipelineState!
    var drawDotPass : MTLComputePipelineState!
    
    var gravityCenterPosition = float2(400,400)
    
    var particleCount = 10000
    var particleBuffer : MTLBuffer!
    
    public override func layoutSubviews() {
        
        self.framebufferOnly = false
        self.device = MTLCreateSystemDefaultDevice()
        commandQueue = device?.makeCommandQueue()
        
        
        let library = try! device?.makeLibrary(source: Shaders.shader_Vertex_Function, options: nil)
        let clear_Func = library?.makeFunction(name: "clear_pass_func")
        let draw_Dot_Func = library?.makeFunction(name: "draw_Dots_Func")
        
        do {
            
            drawDotPass = try? device?.makeComputePipelineState(function: draw_Dot_Func!)
            clearPass = try? device?.makeComputePipelineState(function: clear_Func!)
            
            
        } catch let error as NSError {
            print(error)
        }
        
        createParticles()
        
    }
    
    
    func createParticles(){
        
        var particles : [Particle] = []
        
        for _ in 0..<particleCount{
            
            var positionX = Float.random(in: 10...1600)
            var positionY = Float.random(in: 10...1600)
            var velocityX = (Float(arc4random() % 10) - 5) / 10.0
            var velocityY = (Float(arc4random() % 10) - 5) / 10.0
            
            
            let particle = Particle(color: float4(1), position: float2(positionX,positionY), velocity: float2(velocityX,velocityY), mass: 10.0)
            particles.append(particle)
        }
        
        particleBuffer = device?.makeBuffer(bytes: particles, length: MemoryLayout<Particle>.size * particleCount, options: [])
        
        print(particles.count)
        
        
        print(gravityCenterPosition)
        
    }
    
    
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let loc = t.location(in: self)

            gravityCenterPosition.x = Float(loc.x * 2)


        }
    }


    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let loc = t.location(in: self)

            gravityCenterPosition.x = Float(loc.x * 2)


        }
    }
    
    
    
}

extension MainView{
    

    public override func draw(_ dirtyRect: CGRect){
        
        guard let drawable = self.currentDrawable else {return}

        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let computeCommandEncoder = commandBuffer?.makeComputeCommandEncoder()
        
        
        computeCommandEncoder?.setComputePipelineState(clearPass)
        computeCommandEncoder?.setTexture(drawable.texture, index: 0)
        
        let w = clearPass.threadExecutionWidth
        let h = clearPass.maxTotalThreadsPerThreadgroup / w
        
        
        var xxx = GCenter(position: gravityCenterPosition, mass: 5.0, g: 1.0)
        let bufferGravity = device!.makeBuffer(bytes: &xxx, length: MemoryLayout<GCenter>.size * 1, options: [])
        computeCommandEncoder?.setBuffer(bufferGravity, offset: 0, index: 1)
        
        
        var threadsPerGrid = MTLSize(width: drawable.texture.width, height: drawable.texture.height, depth: 1)
        var threadsPerThreadGroup = MTLSize(width: w, height: h, depth: 1)
        computeCommandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
        
        
        
        computeCommandEncoder?.setComputePipelineState(drawDotPass)
        computeCommandEncoder?.setBuffer(particleBuffer, offset: 0, index: 0)
        threadsPerGrid = MTLSize(width: particleCount, height: 1, depth: 1)
        threadsPerThreadGroup = MTLSize(width: w, height: 1, depth: 1)
        computeCommandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
        
        
        
        
        computeCommandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
    }


}
