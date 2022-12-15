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
                .map { AppAction.synchronizeProgress(id: track.id, time: $0)}
                .eraseToAnyPublisher()

        case .pauseTrack:
            service.pause()
        default:
            break
        }

        return Empty().eraseToAnyPublisher()
    }
}
