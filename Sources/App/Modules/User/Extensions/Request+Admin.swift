import Vapor

extension Request {
    var admin: User {
        get {
            self.storage[User.StorageKey.self]!
        }
        set {
            self.storage[User.StorageKey.self] = newValue
        }
    }
}
