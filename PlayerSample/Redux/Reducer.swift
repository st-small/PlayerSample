import Foundation


typealias Reducer<State, Action> = (inout State, Action) -> Void

func appReducer(state: inout AppState, action: AppAction) -> Void {
    switch action {
    case .fetchAudioItemsComplete(let items):
        state.audioItemsState.audioItems = items
        
    case .playTrack(let id):
        state.audioItemsState.pauseRequest = nil
        state.audioItemsState.audioItems.indices.forEach { idx in
            state.audioItemsState.audioItems[idx].state = state.audioItemsState.audioItems[idx].id == id ? .play : .pause
            if state.audioItemsState.audioItems[idx].id == id {
                state.audioItemsState.playRequest = state.audioItemsState.audioItems[idx]
                state.audioItemsState.updateRequest = state.audioItemsState.audioItems[idx]
            }
        }
        
        state.floatingBarState.currentTrackId = id
        
    case .pauseTrack(let id):
        guard let trackIdx = state.audioItemsState.audioItems.firstIndex(where: { $0.id == id }) else {
            preconditionFailure("Unexpected state")
        }
        state.audioItemsState.audioItems[trackIdx].state = .pause
        state.audioItemsState.playRequest = nil
        state.audioItemsState.updateRequest = nil
        state.audioItemsState.pauseRequest = state.audioItemsState.audioItems[trackIdx]
    
    case .seek(let id, let to):
        let playingTrack = state.audioItemsState.audioItems.first(where: { $0.state == .play || $0.state == .rewind })
        guard let trackIdx = state.audioItemsState.audioItems.firstIndex(where: { $0.id == id }) else {
            preconditionFailure("Unexpected state")
        }
        
        
        if playingTrack == state.audioItemsState.audioItems[trackIdx] {
            state.audioItemsState.audioItems[trackIdx].state = .rewind
            state.audioItemsState.audioItems[trackIdx].time = to
            
            state.audioItemsState.playRequest = nil
            state.audioItemsState.updateRequest = nil
            state.audioItemsState.pauseRequest = state.audioItemsState.audioItems[trackIdx]
        } else {
            state.audioItemsState.audioItems[trackIdx].state = .pause
            state.audioItemsState.audioItems[trackIdx].time = to
        }
        
    case .endSeek(let id):
        let playingTrack = state.audioItemsState.audioItems.first(where: { $0.state == .rewind })
        guard let trackIdx = state.audioItemsState.audioItems.firstIndex(where: { $0.id == id }) else {
            preconditionFailure("Unexpected state")
        }
        
        if playingTrack == state.audioItemsState.audioItems[trackIdx] {
            state.audioItemsState.audioItems[trackIdx].state = .play
            state.audioItemsState.pauseRequest = nil
            state.audioItemsState.playRequest = state.audioItemsState.audioItems[trackIdx]
            state.audioItemsState.updateRequest = state.audioItemsState.audioItems[trackIdx]
        } else {
            state.audioItemsState.audioItems[trackIdx].state = .pause
        }
        
    case .synchronizeProgress(let id, let time):
        guard let trackIdx = state.audioItemsState.audioItems.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        state.audioItemsState.playRequest = nil
        state.audioItemsState.pauseRequest = nil
        
        state.audioItemsState.audioItems[trackIdx].time = time
        
        if let track = state.audioItemsState.audioItems.first(where: { $0.state == .play }) {
            state.audioItemsState.updateRequest = track
        } else {
            state.audioItemsState.updateRequest = nil
        }
        
    case .endPlayerSession:
        state.floatingBarState.currentTrackId = nil
        
        if let playingTrack = state.audioItemsState.audioItems.first(where: { $0.state == .play }) {
            state.audioItemsState.pauseRequest = playingTrack
        }
        
    case .nop:
        break
    }
}
