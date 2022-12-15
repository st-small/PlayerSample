import AVKit
import Combine

// Старая реализация сервиса, который выступает классом-синглтоном для работы с реализацией работы воспроизведения звуков
/*
protocol AudioProviding {
    
    var currentItem: AudioItem? { get }
    var playingIDPublisher: Published<String>.Publisher { get }
    var progressValuePublisher: Published<TimeInterval>.Publisher { get }
    
    func prepare(id: String, url: URL)
    func play(id: String)
    func pause()
    func seek(id: String, to: TimeInterval)
    func duration(id: String) -> TimeInterval
    func currentTime(id: String) -> TimeInterval
}

final class AudioProvider: NSObject, AudioProviding {
    
    @Published var playingID: String = ""
    var playingIDPublisher: Published<String>.Publisher { $playingID }
    
    @Published var progressValue: TimeInterval = 0
    var progressValuePublisher: Published<TimeInterval>.Publisher { $progressValue }
    
    var currentItem: AudioItem?
    
    private var audioItems: [String: AudioItem] = [:]
    private var player: AVAudioPlayer?
    private let timer = Timer
        .publish(every: 0.5, on: .main, in: .common)
        .autoconnect()
    
    private var cancellables: Set<AnyCancellable> = []
    
    public override init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Fail to initialize player \(error)")
        }
        
        super.init()
        
        timer.receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let progress = self.player?.currentTime ?? 0
                self.progressValue = progress
                
                self.audioItems[self.playingID]?.time = progress
            }
            .store(in: &cancellables)
    }
    
    func prepare(id: String, url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let player = try AVAudioPlayer(contentsOf: url)
            let duration = player.duration
            
//            audioItems[id] = .init(id: id, url: url, time: 0, duration: duration)
            
        } catch {
            print("Fail to initialize player \(error)")
        }
    }
    
    func play(id: String) {
        guard let itemToPlay = audioItems[id] else { return }
        currentItem = itemToPlay
        
        do {
            player = try AVAudioPlayer(contentsOf: itemToPlay.url)
            player?.prepareToPlay()
        } catch {
            print(error)
        }
        
        player?.delegate = self
        player?.currentTime = itemToPlay.time
        player?.play()
        
        playingID = itemToPlay.id
    }
    
    func pause() {
        player?.pause()
        playingID = ""
    }
    
    func seek(id: String, to: TimeInterval) {
        player?.currentTime = to
        audioItems[id]?.time = to
    }
    
    func duration(id: String) -> TimeInterval {
        audioItems[id]?.duration ?? 0
    }
    
    func currentTime(id: String) -> TimeInterval {
        audioItems[id]?.time ?? 0
    }
}

extension AudioProvider: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.pause()
        player.currentTime = 0
        
        progressValue = 0
        audioItems[playingID]?.time = 0
        playingID = ""
    }
}

private struct AudioProviderKey: InjectionKey {
    static var currentValue: AudioProviding = AudioProvider()
}

extension InjectedValues {
    var audioProvider: AudioProviding {
        get { Self[AudioProviderKey.self] }
        set { Self[AudioProviderKey.self] = newValue }
    }
}
*/
