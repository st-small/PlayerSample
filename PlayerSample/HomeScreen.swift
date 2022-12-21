//
//  HomeScreen.swift
//  PlayerSample
//
//  Created by Stanly Shiyanovskiy on 19.12.2022.
//

import SwiftUI

struct HomeScreen: View {
    
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        NavigationView {
            ZStack {
                Text("Sample player app")
                    .font(.headline)
                
                if
                    let track = playerSessionTrack() {
                    
                    SoundBarView(
                        title: track.title,
                        duration: track.duration,
                        currentTime: track.time,
                        isPlaying: track.state == .play) {
                            if track.state == .play {
                                store.dispatch(.pauseTrack(id: track.id))
                            } else {
                                store.dispatch(.playTrack(id: track.id))
                            }
                        } onSeek: { time in
                            store.dispatch(.seek(id: track.id, to: time))
                        } endSeek: {
                            store.dispatch(.endSeek(id: track.id))
                        } endSession: {
                            store.dispatch(.endPlayerSession)
                        }

                }
            }
            .toolbar {
                NavigationLink {
                    ContentViewList()
                        .environmentObject(store)
                } label: {
                    Text("Open track list")
                }
            }
        }
    }
    
    private func playerSessionTrack() -> AudioItem? {
        let playerSessionId = store.state.playerSessionTrack
        return store.state.audioItems.first(where: { $0.id == playerSessionId })
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
            .environmentObject(store)
    }
}

struct SoundBarView: View {
    
    // Props
    var title: String
    var duration: TimeInterval
    var currentTime: TimeInterval
    var isPlaying: Bool
    
    // Commands
    var onPlayPause: () -> Void
    var onSeek: (TimeInterval) -> Void
    var endSeek: () -> Void
    var endSession: () -> Void
    
    private let timer = Timer
        .publish(every: 0.1, on: .main, in: .common)
        .autoconnect()
    
    @State private var sliderValue: TimeInterval = 0
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Rectangle()
                    .fill(.secondary)
                
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
                            Slider(value: $sliderValue, in: 0...duration) { editing in

                                onSeek(sliderValue)

                                if !editing {
                                    endSeek()
                                }
                            }
                            
                            HStack {
                                Text(DateComponentsFormatter.positional.string(from: sliderValue) ?? "0:00")
                                
                                Spacer()
                                
                                Text(DateComponentsFormatter.positional.string(from: duration - sliderValue) ?? "0:00")
                            }
                        }
                    }
                }
                .padding()
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    endSession()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                }
                .padding(10)
                .foregroundColor(.primary)
            }
            .frame(height: 130)
            .cornerRadius(15)
            .padding()
            .padding(.bottom, 35)
        }
        .onAppear {
            sliderValue = currentTime
        }
        .onReceive(timer) { _ in
            if isPlaying { sliderValue += 0.1 }
        }
    }
}

struct SoundBarView_Previews: PreviewProvider {
    static var previews: some View {
        SoundBarView(
            title: "Track",
            duration: 1700,
            currentTime: 0,
            isPlaying: false,
            onPlayPause: { },
            onSeek: { _ in },
            endSeek: { },
            endSession: { }
        )
    }
}
