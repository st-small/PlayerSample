import AVKit
import Combine

public enum AudioServiceResultType {
    case playing(TimeInterval), end
}

public protocol AudioServiceProviding {
    func pause()
    func play(trackUrl: URL, time: TimeInterval) -> AnyPublisher<AudioServiceResultType, Never>
}

final class AudioServiceProvider: NSObject, AudioServiceProviding, AVAudioPlayerDelegate {
    
    private let timer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()
    
    private var player: AVAudioPlayer?
    private var cancellables: Set<AnyCancellable> = []
    
    private var sync = PassthroughSubject<AudioServiceResultType, Never>()
    
    override init() {
        super.init()
        
        timer.receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let player = self?.player else { return }
                
                self?.sync.send(.playing(player.currentTime))
            }
            .store(in: &cancellables)
    }
    
    func play(trackUrl: URL, time: TimeInterval) -> AnyPublisher<AudioServiceResultType, Never> {
        sync = PassthroughSubject<AudioServiceResultType, Never>()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: trackUrl)
            player?.prepareToPlay()
            player?.currentTime = time
            player?.play()
            
            player?.delegate = self
            
        } catch {
            print("Fail to initialize player \(error)")
        }
        
        return sync.eraseToAnyPublisher()
    }
    
    func pause() {
        player?.pause()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        sync.send(.end)
    }
}
