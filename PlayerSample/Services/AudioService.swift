import AVKit
import Combine

public protocol AudioServiceProviding {
    func pause()
    func seek(to: TimeInterval)
    func play(trackUrl: URL, time: TimeInterval) -> AnyPublisher<TimeInterval, Never>
}

final class AudioServiceProvider: NSObject, AudioServiceProviding, AVAudioPlayerDelegate {
    
    private let timer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()
    
    private var player: AVAudioPlayer?
    private var cancellables: Set<AnyCancellable> = []
    
    private var sync = PassthroughSubject<TimeInterval, Never>()
    
    override init() {
        super.init()
        
        timer.receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let player = self?.player else { return }
                
                self?.sync.send(player.currentTime)
            }
            .store(in: &cancellables)
    }
    
    func play(trackUrl: URL, time: TimeInterval) -> AnyPublisher<TimeInterval, Never> {
        sync = PassthroughSubject<TimeInterval, Never>()
        
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
    
    func seek(to: TimeInterval) {
        player?.currentTime = to
    }
}
