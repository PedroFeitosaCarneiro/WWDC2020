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

    var keys : [keybord_Key] = []
    
    
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
        
        SoundControl.shared.playSound(soundName: "bgSound")
 
        createKeys()
        createParticles()
    }
    
    
    func createKeys(){
        
        var t1 = keybord_Key(area: CGRect(x: 0, y: 0, width: 200, height: 200), song: "S1", timer: 5, isPlaying: false)
        var t2 = keybord_Key(area: CGRect(x: 200, y: 0, width: 200, height: 200), song: "S2", timer: 6, isPlaying: false)
        var t3 = keybord_Key(area: CGRect(x: 0, y: 200, width: 200, height: 200), song: "S3", timer: 4, isPlaying: false)
        var t4 = keybord_Key(area: CGRect(x: 200, y: 200, width: 200, height: 200), song: "S4", timer: 4, isPlaying: false)
        
        var t5 = keybord_Key(area: CGRect(x: 400, y: 0, width: 200, height: 200), song: "S5", timer: 5, isPlaying: false)
        var t6 = keybord_Key(area: CGRect(x: 600, y: 0, width: 200, height: 200), song: "S6", timer: 4, isPlaying: false)
        var t7 = keybord_Key(area: CGRect(x: 400, y: 200, width: 200, height: 200), song: "S7", timer: 6, isPlaying: false)
        var t8 = keybord_Key(area: CGRect(x: 600, y: 200, width: 200, height: 200), song: "S8", timer: 5, isPlaying: false)
        
        var t9 = keybord_Key(area: CGRect(x: 0, y: 400, width: 200, height: 200), song: "S9", timer: 6, isPlaying: false)
        var t10 = keybord_Key(area: CGRect(x: 200, y: 400, width: 200, height: 200), song: "S10", timer: 7, isPlaying: false)
        var t11 = keybord_Key(area: CGRect(x: 0, y: 600, width: 200, height: 200), song: "S11", timer: 5, isPlaying: false)
        var t12 = keybord_Key(area: CGRect(x: 200, y: 600, width: 200, height: 200), song: "S12", timer: 6, isPlaying: false)

        var t13 = keybord_Key(area: CGRect(x: 400, y: 400, width: 200, height: 200), song: "S13", timer: 7, isPlaying: false)
        var t14 = keybord_Key(area: CGRect(x: 600, y: 400, width: 200, height: 200), song: "S14", timer: 5, isPlaying: false)
        var t15 = keybord_Key(area: CGRect(x: 400, y: 600, width: 200, height: 200), song: "S15", timer: 6, isPlaying: false)
        var t16 = keybord_Key(area: CGRect(x: 600, y: 600, width: 200, height: 200), song: "S3", timer: 4, isPlaying: false)

        keys.append(t1)
        keys.append(t2)
        keys.append(t3)
        keys.append(t4)
        keys.append(t5)
        keys.append(t6)
        keys.append(t7)
        keys.append(t8)
        keys.append(t9)
        keys.append(t10)
        keys.append(t11)
        keys.append(t12)
        keys.append(t13)
        keys.append(t14)
        keys.append(t15)
        keys.append(t16)
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

            let particle = Particle(color: randomColor, position: float2(positionX,positionY), velocity: float2(0,0), acceleration: float2(0,0), mass: Float.random(in: 0.1 ... 100))
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
            
            for i in keys{
                if i.area.contains(loc){
                    print(i.song)
                    i.canPlay(timerP: i.timer, songP: i.song, state: i.isPlaying)
                }
            }
            
        }
    }


    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let loc = t.location(in: self)
            
            xxx.exists = 1
            gravityCenterPosition.x = Float(loc.x * 2)
            gravityCenterPosition.y = Float(loc.y * 2)
            
            for i in keys{
                if i.area.contains(loc){
                    print(i.song)
                    i.canPlay(timerP: i.timer, songP: i.song, state: i.isPlaying)
                }
            }

            

        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        xxx.exists = 0
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
        
    }


}

