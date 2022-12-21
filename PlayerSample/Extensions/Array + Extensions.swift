import AVKit

extension Array where Element == AudioItem {
    func durationsMap() -> Self {
        var items = self
        items.indices.forEach { idx in
            do {
                let player = try AVAudioPlayer(contentsOf: items[idx].url)
                items[idx].duration = player.duration
            } catch {
                print("Fail to calculate track's duration \(error)")
            }
        }
        
        return items
    }
}
