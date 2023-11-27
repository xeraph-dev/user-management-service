import Vapor

extension User {
    struct Create: Content {
        var name: String
        var email: String
        var password: String
        var confirmPassword: String
        var roleId: UUID

        func user() throws -> User {
            let role = Role()
            role.id = roleId
            return try User(
                name: name,
                email: email,
                password: Bcrypt.hash(password),
                role: role
            )
        }
    }
}

extension User.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
        validations.add("confirmPassword", as: String.self, is: !.empty)
        validations.add("roleId", as: UUID.self)
    }
}
