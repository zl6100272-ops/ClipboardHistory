import Foundation
import GRDB

final class DatabaseManager {
    private let dbQueue: DatabaseQueue

    init() throws {
        let appSupport = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("com.clipboard-history", isDirectory: true)

        try FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true, attributes: nil)
        dbQueue = try DatabaseQueue(path: appSupport.appendingPathComponent("clipboard.sqlite").path)
        try migrator.migrate(dbQueue)
    }

    func insert(_ item: ClipboardItem) throws {
        try dbQueue.write { db in
            try item.insert(db)
            try trimHistory(db)
        }
    }

    func latest(limit: Int = 100, search: String = "", type: ClipboardItemType? = nil) throws -> [ClipboardItem] {
        try dbQueue.read { db in
            var request = ClipboardItem.order(ClipboardItem.Columns.createdAt.desc).limit(limit)

            if let type {
                request = request.filter(ClipboardItem.Columns.type == type.rawValue)
            }

            if !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                request = request.filter(ClipboardItem.Columns.content.like("%\(search)%"))
            }

            return try request.fetchAll(db)
        }
    }

    func mostRecent() throws -> ClipboardItem? {
        try dbQueue.read { db in
            try ClipboardItem.order(ClipboardItem.Columns.createdAt.desc).fetchOne(db)
        }
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("createClipboardItems") { db in
            try db.create(table: ClipboardItem.databaseTableName) { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("type", .text).notNull()
                table.column("content", .text).notNull()
                table.column("thumbnail_path", .text)
                table.column("created_at", .datetime).notNull().indexed()
            }
        }
        return migrator
    }

    private func trimHistory(_ db: Database) throws {
        let staleIds = try Int64.fetchAll(
            db,
            sql: """
            SELECT id FROM clipboard_items
            ORDER BY created_at DESC
            LIMIT -1 OFFSET 100
            """
        )

        guard !staleIds.isEmpty else { return }
        try ClipboardItem.deleteAll(db, ids: staleIds)
    }
}
