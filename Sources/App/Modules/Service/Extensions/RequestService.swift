import Vapor

extension Service {
    struct StorageKey: Vapor.StorageKey {
        typealias Value = Service
    }
}

extension Request {
    var service: Service {
        get {
            self.storage[Service.StorageKey.self]!
        }
        set {
            self.storage[Service.StorageKey.self] = newValue
        }
    }
}
