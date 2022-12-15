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
    
    case .seek(let id, let to):
        guard let trackIdx = state.audioItems.firstIndex(where: { $0.id == id }) else {
            preconditionFailure("Unexpected state")
        }
        state.audioItems[trackIdx].time = to
     
    case .pauseTrack(let id):
        guard let trackIdx = state.audioItems.firstIndex(where: { $0.id == id }) else {
            preconditionFailure("Unexpected state")
        }
        state.audioItems[trackIdx].state = .pause
        
    case .synchronizeProgress(let id, let time):
        guard let trackIdx = state.audioItems.firstIndex(where: { $0.id == id }) else {
            preconditionFailure("Unexpected state")
        }
        state.audioItems[trackIdx].time = time
        
    case .nop:
        break
    }
}
