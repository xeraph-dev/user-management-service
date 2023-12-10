import Vapor

extension Role {
    struct Create: Content {
        var name: String

        func role(service: Service) throws -> Role {
            try Role(name: name, service: service)
        }
    }
}

extension Role.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
    }
}
