@testable import App
import Fakery
import XCTVapor

final class UserControllerTests: XCTestCase {
    func testIndex() async throws {
        let faker = Faker(locale: "en-US")
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)

        let system = try await User.system(on: app.db)
        var expected: [User] = []
        while expected.count < 3 {
            let user = User(name: faker.internet.username(),
                            email: faker.internet.email(),
                            password: faker.internet.password(minimumLength: 8, maximumLength: 10))
            if let _ = try? await user.create(on: app.db, by: system) {
                expected.append(user)
            }
        }

        try app.test(.GET, "users", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let actual = try res.content.decode([User.Response].self)
            XCTAssertEqual(actual.count, expected.count)
            for (expected, actual) in zip(expected, actual) {
                XCTAssertEqual(actual.name, expected.name)
                XCTAssertEqual(actual.email, expected.email)
            }
        })

        for user in expected {
            try await user.delete(on: app.db)
        }
    }

    func testCreate() async throws {
        let faker = Faker(locale: "en-US")
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)

        let system = try await User.system(on: app.db)
        let password = faker.internet.password(minimumLength: 8, maximumLength: 10)
        var expected = User.Create(name: faker.internet.username(),
                                   email: faker.internet.email(),
                                   password: password,
                                   confirmPassword: password)

        try app.test(.POST, "users", beforeRequest: { req in
            try req.content.encode(expected)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)

            let expected = try expected.user().response()
            let actual = try res.content.decode(User.Response.self)

            XCTAssertEqual(actual.name, expected.name)
            XCTAssertEqual(actual.email, expected.email)
        })
    }
}
