import Foundation
import GRDB

enum ClipboardItemType: String, Codable, CaseIterable, Identifiable {
    case text
    case image
    case file

    var id: String { rawValue }
}

struct ClipboardItem: Codable, FetchableRecord, PersistableRecord, Identifiable, Equatable {
    static let databaseTableName = "clipboard_items"

    var id: Int64?
    var type: ClipboardItemType
    var content: String
    var thumbnailPath: String?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case content
        case thumbnailPath = "thumbnail_path"
        case createdAt = "created_at"
    }

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let type = Column(CodingKeys.type)
        static let content = Column(CodingKeys.content)
        static let thumbnailPath = Column(CodingKeys.thumbnailPath)
        static let createdAt = Column(CodingKeys.createdAt)
    }
}
