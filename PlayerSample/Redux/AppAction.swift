import Foundation

enum AppAction {
    // Предварительное получение треков на старте приложения
    case fetchAudioItemsComplete([AudioItem])
    
    // Работа с плеером
    // Запуск трека на вопсроизведение
    case playTrack(id: String)
    
    // Пауза трека, который исполняется
    case pauseTrack(id: String)
    
    // Промотка трека к необходимому месту с помощью слайдера
    case seek(id: String, to: TimeInterval)
    
    // Получение уведомления о том, что пользователь закончил промотку трека
    case endSeek(id: String)
    
    // Синхронизация текущего состояния исполнения между плеером и отображением прогресса
    case synchronizeProgress(id: String, result: AudioServiceResultType)
    
    case endPlayerSession
    
    case nop
}

