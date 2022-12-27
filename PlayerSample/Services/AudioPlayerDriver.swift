import Foundation

enum PlayerError: Error {
    case trackIsNotPlaying
}

struct AudioPlayerDriver {
    typealias Operator = AudioPlayerOperator
    typealias Operation = Operator.Operation
    typealias PlayItemOperation = Operator.PlayItem
    typealias PauseItemOperation = Operator.PauseItem
    typealias UpdateItemOperation = Operator.UpdateItem
    
    let store: AppStore
    let `operator`: AudioPlayerOperator
    
    func subscribe(_ component: AudioPlayerOperator) -> Observer<AppState> {
        Observer(queue: self.operator.queue) { state in
            component.props = map(state: state)
            return .active
        }
    }
    
    func map(state: AppState) -> Operator.Props {
        var operations: [Operation] = []
        
        // MARK: - Play
        if let playingTrack = state.audioItemsState.playRequest {
            let playOperation = PlayItemOperation(
                uuid: UUID().uuidString,
                track: playingTrack) { _ in }
            
            operations.append(playOperation)
        }
        
        if let updateTrack = state.audioItemsState.updateRequest {
            let updateOperation = UpdateItemOperation(
                uuid: UUID().uuidString) { result in
                    if case let .success(time) = result {
                        DispatchQueue.main.async {
                            self.store.dispatch(.synchronizeProgress(id: updateTrack.id, result: time))
                        }
                    }
                }
            
            operations.append(updateOperation)
        }
        
        // MARK: - Pause
        if let pauseTrack = state.audioItemsState.pauseRequest {
            let operation = PauseItemOperation(
                uuid: UUID().uuidString,
                track: pauseTrack) { _ in }
            operations.append(operation)
        }
        
        return operations
    }
}


import AVKit

protocol AudioItemTask {
    var uuid: String { get }
}

final class AudioPlayerOperator: NSObject {
    typealias Operation = AudioItemTask
    typealias Props = [Operation]
    typealias WorkItem = DispatchWorkItem
    
    let queue = DispatchQueue(label: "audio.player.com")
    private var active: [String: (operation: Operation, work: WorkItem)] = [:]
    private var completed: Set<String> = []
    
    private var player: AVAudioPlayer!
    
    var props: Props = [] {
        didSet {
            var remainedActiveIds = Set(active.keys)
            
            for operation in props {
                process(operation: operation)
                remainedActiveIds.remove(operation.uuid)
            }
            
            for cancelled in remainedActiveIds {
                #warning("Тут нужно отменять задачи!")
            }
        }
    }
    
    private func process(operation: Operation) {
        guard !completed.contains(operation.uuid) else { return }
        
        // Если уже есть такая задача, обновляем ее
        if active.keys.contains(operation.uuid) {
            active[operation.uuid]!.operation = operation
        } else {
            var workItem: DispatchWorkItem? {
                switch operation {
                case let operation as PlayItem:
                    return playAudioItem(operation)
                case let operation as PauseItem:
                    return pauseAudioItem(operation)
                case let operation as UpdateItem:
                    return updateAudioItem(operation)
                default:
                    preconditionFailure("Unknown audio task")
                }
            }
            
            guard let toExecute = workItem else { preconditionFailure("DispatchWorkItem is nil") }
            active[operation.uuid] = (operation, toExecute)
            queue.async(execute: toExecute)
        }
    }
    
    private func complete<ResultType>(
        _ operation: Operation,
        _ onComplete: (ResultType) -> Void,
        _ result: ResultType
    ) {
        guard let (operation, _) = active[operation.uuid] else {
            preconditionFailure("Operation not found")
        }

        active[operation.uuid] = nil
        completed.insert(operation.uuid)
        
        onComplete(result)
    }
}

// MARK: - Play audio item operation

extension AudioPlayerOperator {
    struct PlayItem: Operation {
        let uuid: String
        let track: AudioItem
        let onComplete: (Result<Void, Error>) -> Void
    }
    
    func playAudioItem(_ operation: PlayItem) -> DispatchWorkItem? {
        var workItem: DispatchWorkItem?
        workItem = DispatchWorkItem { [weak self] in
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                self?.player = try AVAudioPlayer(contentsOf: operation.track.url)
                self?.player?.prepareToPlay()
                self?.player?.currentTime = operation.track.time
                self?.player?.play()
                
                self?.player.delegate = self
                
                self?.complete(operation, operation.onComplete, .success(()))
            } catch {
                self?.complete(operation, operation.onComplete, .failure(error))
            }
        }
        
        return workItem
    }
}

extension AudioPlayerOperator: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
}

// MARK: - Pause audio item operation

extension AudioPlayerOperator {
    struct PauseItem: Operation {
        let uuid: String
        let track: AudioItem
        let onComplete: (Result<TimeInterval, Error>) -> Void
    }
    
    func pauseAudioItem(_ operation: PauseItem) -> DispatchWorkItem? {
        var workItem: DispatchWorkItem?
        workItem = DispatchWorkItem { [weak self] in
            guard self?.player != nil else { return }
            let currentPlayTime = self?.player.currentTime ?? 0
            self?.player.pause()
            self?.complete(operation, operation.onComplete, .success((currentPlayTime)))
        }
        
        return workItem
    }
}

extension AudioPlayerOperator {
    struct UpdateItem: Operation {
        let uuid: String
        let onUpdate: (Result<TimeInterval, PlayerError>) -> Void
    }
    
    func updateAudioItem(_ operation: UpdateItem) -> DispatchWorkItem? {
        var workItem: DispatchWorkItem?
        workItem = DispatchWorkItem { [weak self] in
            guard let player = self?.player, player.isPlaying else {
                self?.complete(operation, operation.onUpdate, .failure(.trackIsNotPlaying))
                return
            }
            
            self?.complete(operation, operation.onUpdate, .success(player.currentTime))
        }
        
        return workItem
    }
}
