//
//  PlayerSampleApp.swift
//  PlayerSample
//
//  Created by Stanly Shiyanovskiy on 12.12.2022.
//

import SwiftUI

let store = AppStore(
    state: .init(),
    reducer: appReducer,
    middlewares: [playerMiddleware(service: AudioServiceProvider())]
)

@main
struct PlayerSampleApp: App {

    init() {
        let items = [
            AudioItem(
                id: "111",
                title: "Jingle Bells",
                url: Bundle.main.url(forResource: "Merry-Christmas-Jingle-Bells", withExtension: "mp3")!,
                time: 0,
                duration: 0, // Вопрос: Как правильно тут посчитать длину трека???
                state: .pause
            ),
            AudioItem(
                id: "222",
                title: "В лесу родилась ёлочка",
                url: Bundle.main.url(forResource: "v-lesu-rodilas-elochka", withExtension: "mp3")!,
                time: 0,
                duration: 0,
                state: .pause
            )
        ].durationsMap()
        store.dispatch(.fetchAudioItemsComplete(items))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentViewList()
                .environmentObject(store)
        }
    }
}

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
