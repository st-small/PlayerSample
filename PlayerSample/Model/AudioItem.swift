import Foundation

enum AudioItemState {
    case pause, play, rewind
}

struct AudioItem: Equatable, Identifiable {
    let id: String
    let title: String
    let url: URL
    var time: TimeInterval
    var duration: TimeInterval
    var state: AudioItemState
}
