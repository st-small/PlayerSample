import Foundation

struct AppState: Equatable {
    var audioItemsState = AudioItemsState()
    var floatingBarState = FloatingAudioBarState()
}

struct AudioItemsState: Equatable {
    var playRequest: AudioItem?
    var pauseRequest: AudioItem?
    var updateRequest: AudioItem?
    var audioItems: [AudioItem] = []
}

struct FloatingAudioBarState: Equatable {
    var currentTrackId: String?
}
