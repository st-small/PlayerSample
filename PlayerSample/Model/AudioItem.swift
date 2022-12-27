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

extension AudioItem {
    static var empty: AudioItem {
        AudioItem(
            id: "",
            title: "",
            url: URL(string: "")!,
            time: 0,
            duration: 500,
            state: .pause
        )
    }
}
