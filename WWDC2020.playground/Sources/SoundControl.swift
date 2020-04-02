import AVFoundation


class SoundControl: NSObject, AVAudioPlayerDelegate {
    
    static let shared = SoundControl()
    
    private override init() {}
    
    var players : [URL:AVAudioPlayer] = [:]
    var duplicatePlayers : [AVAudioPlayer] = []
    
    func playSound(soundName: String){
        guard let filePath: String = Bundle.main.path(forResource: soundName, ofType: "wav") else{ return }
        let fileURL: URL = URL(fileURLWithPath: filePath)
        
        if let player = players[fileURL]{
            
            if !player.isPlaying {
                player.prepareToPlay()
                player.play()
            } else {
                
                do {
                    let duplicatePlayer = try AVAudioPlayer(contentsOf: fileURL)

                    duplicatePlayer.delegate = self

                    duplicatePlayers.append(duplicatePlayer)
                    duplicatePlayer.prepareToPlay()
                    duplicatePlayer.play()
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        } else {
            
            
            do {
                let player = try AVAudioPlayer(contentsOf: fileURL)
                players[fileURL] = player
                player.prepareToPlay()
                player.play()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    func playSounds(soundFileNames: [String]) {
        for soundFileName in soundFileNames {
            playSound(soundName: soundFileName)
        }
    }

    func playSounds(soundFileNames: String...) {
        for soundFileName in soundFileNames {
            playSound(soundName: soundFileName)
        }
    }
    
    
}
