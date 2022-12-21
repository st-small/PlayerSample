import Foundation


typealias Reducer<State, Action> = (inout State, Action) -> Void

func appReducer(state: inout AppState, action: AppAction) -> Void {
    switch action {
    case .fetchAudioItemsComplete(let items):
        state.audioItems = items
        
    case .playTrack(let id):
        state.audioItems.indices.forEach { idx in
            state.audioItems[idx].state = state.audioItems[idx].id == id ? .play : .pause
        }
        state.playerSessionTrack = id
    
    case .seek(let id, let to):
        guard let trackIdx = state.audioItems.firstIndex(where: { $0.id == id }) else {
            preconditionFailure("Unexpected state")
        }
        let currentState = state.audioItems[trackIdx].state
        state.audioItems[trackIdx].state = currentState == .pause ? .pause : .rewind
        state.audioItems[trackIdx].time = to
        
    case .endSeek(let id):
        guard let trackIdx = state.audioItems.firstIndex(where: { $0.id == id }) else {
            preconditionFailure("Unexpected state")
        }
        let currentState = state.audioItems[trackIdx].state
        state.audioItems[trackIdx].state = currentState == .rewind ? .play : .pause
     
    case .pauseTrack(let id):
        guard let trackIdx = state.audioItems.firstIndex(where: { $0.id == id }) else {
            preconditionFailure("Unexpected state")
        }
        state.audioItems[trackIdx].state = .pause
        
    case .synchronizeProgress(let id, let result):
        guard let trackIdx = state.audioItems.firstIndex(where: { $0.id == id }) else {
            preconditionFailure("Unexpected state")
        }
        
        switch result {
        case .playing(let timeInterval):
            state.audioItems[trackIdx].time = timeInterval
        case .end:
            state.audioItems[trackIdx].time = 0
            state.audioItems[trackIdx].state = .pause
        }
        
    case .endPlayerSession:
        state.playerSessionTrack = ""
        
    case .nop:
        break
    }
}
