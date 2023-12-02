import Vapor

extension Service {
    struct Create: Content {
        var name: String

        func service() throws -> Service {
            Service(name: name)
        }
    }
}

extension Service.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
    }
}
