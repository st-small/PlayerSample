import Combine
import Foundation


typealias AppStore = Store<AppState, AppAction>

final class Store<State, Action>: ObservableObject {
    @Published private(set) var state: State
    let middlewares: [Middleware<State, Action>]
    let reducer: Reducer<State, Action>
    private var middlewareCancellables: Set<AnyCancellable> = []
    
    private let queue = DispatchQueue(label: "store.com", qos: .userInitiated)
    private var observers: Set<Observer<State>> = []
    
    init(
        state: State,
        reducer: @escaping Reducer<State, Action>,
        middlewares: [Middleware<State, Action>]
    ) {
        self.state = state
        self.reducer = reducer
        self.middlewares = middlewares
    }
    
    func dispatch(_ action: Action) {
        reducer(&state, action)
        guard Thread.isMainThread else {
            preconditionFailure()
        }
        
        for middleware in middlewares {
            guard let middleware = middleware(state, action) else { break }
            middleware
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: dispatch)
                .store(in: &middlewareCancellables)
        }
        
        observers.forEach(notify)
    }
    
    func subscribe(observer: Observer<State>) {
        observers.insert(observer)
        notify(observer)
    }
    
    private func notify(_ observer: Observer<State>) {
        let state = self.state
        observer.queue.async {
            let status = observer.observe(state)
            
            if case .dead = status {
                self.queue.async {
                    self.observers.remove(observer)
                }
            }
        }
    }
}

class Observer<State>: Hashable {
    static func == (lhs: Observer<State>, rhs: Observer<State>) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }
    
    enum Status {
        case active
        case postponed(Int)
        case dead
    }
    
    let queue: DispatchQueue
    let observe: (State) -> Status
    
    init(queue: DispatchQueue, observe: @escaping (State) -> Status) {
        self.queue = queue
        self.observe = observe
    }
}
