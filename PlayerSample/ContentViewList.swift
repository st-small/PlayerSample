//
//  ContentView.swift
//  PlayerSample
//
//  Created by Stanly Shiyanovskiy on 12.12.2022.
//

import SwiftUI

struct ContentViewListConnector: Connector {
    func map(store: AppStore) -> some View {
        let items = store.state.audioItemsState.audioItems
        
        return ContentViewList(audioItems: items)
    }
}

struct ContentViewList: View {

    let audioItems: [AudioItem]
    
    var body: some View {
        ScrollView(.vertical) {
            ForEach(audioItems) { item in
                SoundViewConnector(id: item.id)
            }
        }
        .padding()
    }
}

struct SoundViewConnector: Connector {
    
    let id: String
    
    func map(store: AppStore) -> some View {
        let item = store.state.audioItemsState.audioItems.first(where: { $0.id == id })
        let isPlaying = item?.state == .play

        return SoundView(
            title: item?.title ?? "",
            duration: item?.duration ?? 500,
            currentTime: Binding(
                get: { item?.time ?? 0 },
                set: { store.dispatch(.seek(id: item?.id ?? "", to: $0)) }),
            isPlaying: isPlaying,
            onPlayPause: { store.dispatch(isPlaying ? .pauseTrack(id: id) : .playTrack(id: id)) },
            onSeek: { interval in store.dispatch(.seek(id: id, to: interval)) },
            endSeek: { store.dispatch(.endSeek(id: id)) }
        )
    }
}

struct SoundView: View {
    
    // Props
    var title: String
    var duration: TimeInterval
    @Binding var currentTime: TimeInterval
    var isPlaying: Bool
    
    // Commands
    var onPlayPause: () -> Void
    var onSeek: (TimeInterval) -> Void
    var endSeek: () -> Void
    
//    private let timer = Timer
//        .publish(every: 0.1, on: .main, in: .common)
//        .autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
            HStack {
                Button {
                    onPlayPause()
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 40))
                }
                
                VStack {
                    Slider(value: $currentTime, in: 0...duration) { editing in
                        
                        onSeek(currentTime)
                        
                        if !editing {
                            endSeek()
                        }
                    }
                    
                    HStack {
                        Text(DateComponentsFormatter.positional.string(from: currentTime) ?? "0:00")
                        
                        Spacer()
                        
                        Text(DateComponentsFormatter.positional.string(from: duration - currentTime) ?? "0:00")
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
//        .onReceive(timer) { _ in
//            if isPlaying {
//                currentTime += 0.1
//            }
//        }
    }
}
