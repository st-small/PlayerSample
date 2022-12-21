import Combine
import Foundation

typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>?

func playerMiddleware(service: AudioServiceProvider) -> Middleware<AppState, AppAction> {
    return { state, action in
        switch action {
        case .playTrack(let id):
            guard let track = state.audioItems.first(where: { $0.id == id }) else {
                return Just(.nop).eraseToAnyPublisher()
            }
            return service.play(trackUrl: track.url, time: track.time)
                .subscribe(on: DispatchQueue.main)
                .map { AppAction.synchronizeProgress(id: track.id, result: $0) }
                .eraseToAnyPublisher()

        case .pauseTrack:
            service.pause()
            
        case .seek(let id, _):
            guard let track = state.audioItems.first(where: { $0.id == id }), track.state == .rewind else {
                return Just(.nop).eraseToAnyPublisher()
            }
            service.pause()
            
        case .endSeek(let id):
            guard let track = state.audioItems.first(where: { $0.id == id }), track.state == .play else {
                return Just(.nop).eraseToAnyPublisher()
            }
            return service.play(trackUrl: track.url, time: track.time)
                .subscribe(on: DispatchQueue.main)
                .map { AppAction.synchronizeProgress(id: track.id, result: $0) }
                .eraseToAnyPublisher()
            
        default:
            break
        }

        return Empty().eraseToAnyPublisher()
    }
}
