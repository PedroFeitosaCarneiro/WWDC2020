import UIKit


public class keybord_Key{
    
    var area : CGRect
    var song : String
    var timer : Float
    var isPlaying : Bool
    
    
    init(area: CGRect, song: String, timer: Float, isPlaying: Bool) {
        self.area = area
        self.song = song
        self.timer = timer
        self.isPlaying = isPlaying
    }
    
    func canPlay(timerP: Float, songP: String, state: Bool){
        
        if state == true {
        } else {
            self.isPlaying = true
            SoundControl.shared.playSound(soundName: songP)
            Timer.scheduledTimer(withTimeInterval: TimeInterval(timerP), repeats: false) { (_) in
                self.isPlaying = false
            }
        }
    }
    
}
