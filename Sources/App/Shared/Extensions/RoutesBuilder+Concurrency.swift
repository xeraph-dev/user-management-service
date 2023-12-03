import Vapor

public extension RoutesBuilder {
    @discardableResult
    @preconcurrency
    func on(
        _ method: HTTPMethod,
        _ path: [PathComponent],
        body: HTTPBodyStreamStrategy = .collect,
        use closure: @Sendable @escaping (Request) async throws -> Void
    ) -> Route {
        on(method, path, body: body) { (req: Request) -> HTTPStatus in
            try await closure(req)
            return .noContent
        }
    }

    @discardableResult
    @preconcurrency
    func get(
        _ path: PathComponent...,
        use closure: @Sendable @escaping (Request) async throws -> Void
    ) -> Route {
        return on(.GET, path, use: closure)
    }

    @discardableResult
    @preconcurrency
    func post(
        _ path: PathComponent...,
        use closure: @Sendable @escaping (Request) async throws -> Void
    ) -> Route {
        return on(.POST, path, use: closure)
    }

    @discardableResult
    @preconcurrency
    func patch(
        _ path: PathComponent...,
        use closure: @Sendable @escaping (Request) async throws -> Void
    ) -> Route {
        return on(.PATCH, path, use: closure)
    }

    @discardableResult
    @preconcurrency
    func put(
        _ path: PathComponent...,
        use closure: @Sendable @escaping (Request) async throws -> Void
    ) -> Route {
        return on(.PUT, path, use: closure)
    }

    @discardableResult
    @preconcurrency
    func delete(
        _ path: PathComponent...,
        use closure: @Sendable @escaping (Request) async throws -> Void
    ) -> Route {
        return on(.DELETE, path, use: closure)
    }
}
