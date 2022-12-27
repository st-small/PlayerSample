//
//  HomeScreen.swift
//  PlayerSample
//
//  Created by Stanly Shiyanovskiy on 19.12.2022.
//

import SwiftUI

struct HomeScreenConnector: Connector {
    
    func map(store: AppStore) -> some View {
        let playingTrack = store.state.floatingBarState.currentTrackId
        
        return HomeScreen(
            showSoundBar: playingTrack != nil,
            id: playingTrack ?? ""
        )
    }
}

struct HomeScreen: View {
    
    // MARK: - Props
    let showSoundBar: Bool
    let id: String
    
    var body: some View {
        NavigationView {
            ZStack {
                Text("Sample player app")
                    .font(.headline)
                
                if showSoundBar {
                    SoundBarConnector(id: id)
                }
            }
            .toolbar {
                NavigationLink {
                    ContentViewListConnector()
                } label: {
                    Text("Open track list")
                }
            }
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen(showSoundBar: true, id: "")
    }
}

struct SoundBarConnector: Connector {
    
    let id: String
    
    func map(store: AppStore) -> some View {
        let track = store.state.audioItemsState.audioItems.first(where: { $0.id == id })
        let trackId = track?.id ?? ""
        
        return SoundBarView(
            title: track?.title ?? "",
            duration: track?.duration ?? 0,
            currentTime: Binding(
                get: { track?.time ?? 0 },
                set: { store.dispatch(.seek(id: trackId, to: $0)) }
            ),
            isPlaying: track?.state == .play,
            onPlay: { store.dispatch(.playTrack(id: trackId)) },
            onPause: { store.dispatch(.pauseTrack(id: trackId)) },
            onSeek: { store.dispatch(.seek(id: trackId, to: $0)) },
            endSeek: { store.dispatch(.endSeek(id: trackId)) },
            endSession: { store.dispatch(.endPlayerSession) }
        )
    }
}

struct SoundBarView: View {
    
    // Props
    var title: String
    var duration: TimeInterval
    @Binding var currentTime: TimeInterval
    var isPlaying: Bool
    
    // Commands
    var onPlay: () -> Void
    var onPause: () -> Void
    var onSeek: (TimeInterval) -> Void
    var endSeek: () -> Void
    var endSession: () -> Void
    
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
                            isPlaying ? onPause() : onPlay()
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
    }
}

struct SoundBarView_Previews: PreviewProvider {
    static var previews: some View {
        SoundBarView(
            title: "Track",
            duration: 1700,
            currentTime: Binding(
                get: { 100 },
                set: { _ in }
            ),
            isPlaying: false,
            onPlay: { },
            onPause: { },
            onSeek: { _ in },
            endSeek: { },
            endSession: { }
        )
    }
}
