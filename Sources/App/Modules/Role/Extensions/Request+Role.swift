import Vapor

extension Request {
    var role: Role {
        get {
            self.storage[Role.StorageKey.self]!
        }
        set {
            self.storage[Role.StorageKey.self] = newValue
        }
    }
}
