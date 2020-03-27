import PlaygroundSupport
import SpriteKit
import Cocoa

let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 800, height: 800))

let scene = SKScene(size: CGSize(width: 800, height: 800))
sceneView.showsFPS = true
sceneView.presentScene(scene)
PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
