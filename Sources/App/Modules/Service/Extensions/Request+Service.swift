import Vapor

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
