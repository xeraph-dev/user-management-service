@testable import App
import XCTVapor

final class UserEnsureSuperAdminMiddlewareTests: TestCase {
    func testWorks() throws {
        app.grouped("path", "for", "testing")
            .grouped(User.EnsureSuperAdminMiddleware())
            .get { try $0.admin.requireID().uuidString }

        try app.test(.GET, "path/for/testing") { res in
            XCTAssertEqual(res.status, .ok)
            let body = try res.content.decode(String.self)
            XCTAssertEqual(body, try systemUser.requireID().uuidString)
        }
    }
}
