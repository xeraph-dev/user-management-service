import Fluent
import FluentPostgresDriver
import Leaf
import NIOSSL
import Vapor

public func configure(_ app: Application) async throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    try app.databases.use(.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST")!,
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:))!,
        username: Environment.get("DATABASE_USER")!,
        password: Environment.get("DATABASE_PASS")!,
        database: Environment.get("DATABASE_NAME")!,
        tls: .prefer(.init(configuration: .clientDefault))
    )), as: .psql)

    app.migrations.add(User.CreateMigration())

    try await app.autoMigrate()

    app.views.use(.leaf)

    try routes(app)
}
