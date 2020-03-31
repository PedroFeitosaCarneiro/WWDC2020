import Foundation
import UIKit
import MetalKit


struct Particle {
    var color : float4
    var position: float2
    var velocity: float2
    var acceleration : float2
    var mass : Float
}

struct GCenter{
    var position : float2
    var mass : Float
    var g : Float
    var exists : Int
}


public class MainView : MTKView {
    
    var commandQueue : MTLCommandQueue!
    var clearPass : MTLComputePipelineState!
    var drawDotPass : MTLComputePipelineState!
    
    var gravityCenterPosition = float2(800,800)
    var xxx : GCenter!
    
    var particleCount = 500000
    var particleBuffer : MTLBuffer!
    
    public override func layoutSubviews() {
        
        xxx = GCenter(position: gravityCenterPosition, mass: 1.0, g: 1.0, exists: 0)
        
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
        
        //direita inferior
        var teclaSize = UIView(frame: CGRect(x: 400, y: 400, width: 200, height: 200))
        teclaSize.backgroundColor = .white
        self.addSubview(teclaSize)
        
        var teclaSize1 = UIView(frame: CGRect(x: 600, y: 400, width: 200, height: 200))
        teclaSize1.backgroundColor = .blue
        self.addSubview(teclaSize1)
        
        
        var teclaSize3 = UIView(frame: CGRect(x: 400, y: 600, width: 200, height: 200))
        teclaSize3.backgroundColor = .blue
        self.addSubview(teclaSize3)
        
        var teclaSize4 = UIView(frame: CGRect(x: 600, y: 600, width: 200, height: 200))
        teclaSize4.backgroundColor = .white
        self.addSubview(teclaSize4)
        
        
        //esquerda superior
        
        var teclaSizeR1 = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        teclaSizeR1.backgroundColor = .white
        self.addSubview(teclaSizeR1)
        
        var teclaSizeR2 = UIView(frame: CGRect(x: 200, y: 0, width: 200, height: 200))
        teclaSizeR2.backgroundColor = .blue
        self.addSubview(teclaSizeR2)
        
        var teclaSizeR3 = UIView(frame: CGRect(x: 0, y: 200, width: 200, height: 200))
        teclaSizeR3.backgroundColor = .blue
        self.addSubview(teclaSizeR3)
        
        var teclaSizeR4 = UIView(frame: CGRect(x: 200, y: 200, width: 200, height: 200))
        teclaSizeR4.backgroundColor = .white
        self.addSubview(teclaSizeR4)
        
        
        //direita superior
        
        var teclaSizeG1 = UIView(frame: CGRect(x: 400, y: 0, width: 200, height: 200))
        teclaSizeG1.backgroundColor = .white
        self.addSubview(teclaSizeG1)
        
        var teclaSizeG2 = UIView(frame: CGRect(x: 600, y: 0, width: 200, height: 200))
        teclaSizeG2.backgroundColor = .blue
        self.addSubview(teclaSizeG2)
        
        var teclaSizeG3 = UIView(frame: CGRect(x: 400, y: 200, width: 200, height: 200))
        teclaSizeG3.backgroundColor = .blue
        self.addSubview(teclaSizeG3)
        
        var teclaSizeG4 = UIView(frame: CGRect(x: 600, y: 200, width: 200, height: 200))
            teclaSizeG4.backgroundColor = .white
            self.addSubview(teclaSizeG4)
        
        
        //esquerda inferior
        
        var teclaSizeZ1 = UIView(frame: CGRect(x: 0, y: 400, width: 200, height: 200))
        teclaSizeZ1.backgroundColor = .white
        self.addSubview(teclaSizeZ1)
        
        var teclaSizeZ2 = UIView(frame: CGRect(x: 200, y: 400, width: 200, height: 200))
        teclaSizeZ2.backgroundColor = .blue
        self.addSubview(teclaSizeZ2)
        
        var teclaSizeZ3 = UIView(frame: CGRect(x: 0, y: 600, width: 200, height: 200))
        teclaSizeZ3.backgroundColor = .blue
        self.addSubview(teclaSizeZ3)
        
        var teclaSizeZ4 = UIView(frame: CGRect(x: 200, y: 600, width: 200, height: 200))
        teclaSizeZ4.backgroundColor = .white
        self.addSubview(teclaSizeZ4)
        
        
        
        
        
        
        
        
        
    }
    
    
    func createParticles(){
        
        var particles : [Particle] = []
        
        for _ in 0..<particleCount{
            
            var positionX = Float.random(in: 0...1600)
            var positionY = Float.random(in: 0...1600)
            
            var randomColor : float4
            
            switch Int.random(in: 1...3) {
            case 1:
                randomColor = float4((112/255),(213/255),(255/255),1)
            case 2:
                randomColor = float4((112/255),(255/255),(138/255),1)
            case 3:
                randomColor = float4((138/255),(140/255),(255/255),1)
            default:
                randomColor = float4((138/255),(140/255),(255/255),1)
            }
            
            
            
            let particle = Particle(color: randomColor, position: float2(positionX,positionY), velocity: float2(0,0), acceleration: float2(0,0), mass: Float.random(in: 0.1 ... 10))
            particles.append(particle)
        }
        
        particleBuffer = device?.makeBuffer(bytes: particles, length: MemoryLayout<Particle>.stride * particleCount, options: [])
        
    }
    
    
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let loc = t.location(in: self)
            
            xxx.exists = 1

            gravityCenterPosition.x = Float(loc.x * 2)
            gravityCenterPosition.y = Float(loc.y * 2)


        }
    }


    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let loc = t.location(in: self)
            
            xxx.exists = 1

            gravityCenterPosition.x = Float(loc.x * 2)
            gravityCenterPosition.y = Float(loc.y * 2)

        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        xxx.exists = 0
    }
    
    
    
}

extension MainView{
    

    /*public override func draw(_ dirtyRect: CGRect){
        
        guard let drawable = self.currentDrawable else {return}

        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let computeCommandEncoder = commandBuffer?.makeComputeCommandEncoder()
        
        
        
        computeCommandEncoder?.setComputePipelineState(clearPass)
        computeCommandEncoder?.setTexture(drawable.texture, index: 0)
        
        
        let w = clearPass.threadExecutionWidth
        let h = clearPass.maxTotalThreadsPerThreadgroup / w
        
        
        var z = GCenter(position: gravityCenterPosition, mass: 1.0, g: 1.0, exists: xxx.exists)
        let bufferGravity = device!.makeBuffer(bytes: &z, length: MemoryLayout<GCenter>.size * 1, options: [])
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
        
    }*/


}
