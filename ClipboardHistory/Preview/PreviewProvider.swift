import SwiftUI

struct ClipboardHistoryPreviews: PreviewProvider {
    static var previews: some View {
        GridItemView(item: ClipboardItem(
            id: 1,
            type: .text,
            content: "这是一段剪贴板文本预览，用于检查两行摘要的显示效果。",
            thumbnailPath: nil,
            createdAt: Date()
        ))
        .frame(width: 160)
        .padding()
    }
}
