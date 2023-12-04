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
    app.migrations.add(User.InsertSystemMigration())
    app.migrations.add(User.AddModifiedByReferencesMigration())
    app.migrations.add(Service.CreateMigration())
    app.migrations.add(Service.InsertSystemMigration())
    app.migrations.add(Service.User.CreateMigration())
    app.migrations.add(Service.User.AddSystemUserToSystemMigration())
    app.migrations.add(Role.CreateMigration())
    app.migrations.add(Role.InsertSystemMigration())
    app.migrations.add(Service.Role.CreateMigration())
    app.migrations.add(Service.Role.AddSystemRoleToSystemMigration())

    app.views.use(.leaf)

    let api = app.routes.grouped("api")
    let v1 = api.grouped("v1")
    try v1.register(collection: User.Controller())
    try v1.register(collection: Service.Controller())
    try v1.register(collection: Role.Controller())
}
