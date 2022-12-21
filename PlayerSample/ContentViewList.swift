//
//  ContentView.swift
//  PlayerSample
//
//  Created by Stanly Shiyanovskiy on 12.12.2022.
//

import SwiftUI

struct ContentViewList: View {

    @EnvironmentObject var store: AppStore
    
    var body: some View {
        ScrollView(.vertical) {
            ForEach(store.state.audioItems) { item in
                SoundView(
                    title: item.title,
                    duration: item.duration,
                    currentTime: item.time,
                    isPlaying: item.state == .play) {
                        if item.state == .play {
                            store.dispatch(.pauseTrack(id: item.id))
                        } else {
                            store.dispatch(.playTrack(id: item.id))
                        }
                    } onSeek: { interval in
                        store.dispatch(.seek(id: item.id, to: interval))
                    } endSeek: {
                        store.dispatch(.endSeek(id: item.id))
                    }
            }
        }
        .padding()
    }
}

struct SoundView: View {
    
    // Props
    var title: String
    var duration: TimeInterval
    @State var currentTime: TimeInterval
    var isPlaying: Bool
    
    // Commands
    var onPlayPause: () -> Void
    var onSeek: (TimeInterval) -> Void
    var endSeek: () -> Void
    
    private let timer = Timer
        .publish(every: 0.1, on: .main, in: .common)
        .autoconnect()
    
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
        .onReceive(timer) { _ in
            if isPlaying {
                currentTime += 0.1
            }
        }
    }
}
