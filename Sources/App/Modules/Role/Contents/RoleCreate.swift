import Vapor

extension Role {
    struct Create: Content {
        var name: String

        func role() throws -> Role {
            Role(name: name)
        }
    }
}

extension Role.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
    }
}
