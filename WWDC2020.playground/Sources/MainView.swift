import Foundation
import UIKit
import MetalKit


public class MainView : MTKView {
    
    var commandQueue : MTLCommandQueue!
    var clearPass : MTLComputePipelineState!
    
    public override func layoutSubviews() {
        
        self.framebufferOnly = false
        self.device = MTLCreateSystemDefaultDevice()
        commandQueue = device?.makeCommandQueue()
        
        
        let library = try! device?.makeLibrary(source: Shaders.shader_Vertex_Function, options: nil)
        let clear_Func = library?.makeFunction(name: "clear_pass_func")
        
        do {
            
            clearPass = try? device?.makeComputePipelineState(function: clear_Func!)
            
        } catch let error as NSError {
            print(error)
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
        
        
        
        var threadsPerGrid = MTLSize(width: drawable.texture.width, height: drawable.texture.height, depth: 1)
        var threadsPerThreadGroup = MTLSize(width: w, height: h, depth: 1)
        computeCommandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
        
        
        computeCommandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
    }


}
