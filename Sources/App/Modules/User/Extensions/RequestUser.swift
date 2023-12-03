import Vapor

extension Request {
    var user: User {
        get {
            self.storage[User.StorageKey.self]!
        }
        set {
            self.storage[User.StorageKey.self] = newValue
        }
    }
}
