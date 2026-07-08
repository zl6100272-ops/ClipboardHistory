import AppKit
import SwiftUI

struct GridItemView: View {
    let item: ClipboardItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            preview
                .frame(maxWidth: .infinity)
                .frame(height: 104)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(height: 152)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        }
    }

    @ViewBuilder
    private var preview: some View {
        switch item.type {
        case .text:
            Text(item.content)
                .font(.body)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(8)
                .background(Color(nsColor: .textBackgroundColor).opacity(0.45))
        case .image:
            if let image = NSImage(contentsOfFile: item.thumbnailPath ?? item.content) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.05))
            } else {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        case .file:
            let path = firstPath
            VStack(spacing: 8) {
                Image(nsImage: NSWorkspace.shared.icon(forFile: path))
                    .resizable()
                    .frame(width: 48, height: 48)
                Text(URL(fileURLWithPath: path).lastPathComponent)
                    .font(.callout)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(8)
            .background(Color(nsColor: .textBackgroundColor).opacity(0.45))
        }
    }

    private var iconName: String {
        switch item.type {
        case .text: "text.alignleft"
        case .image: "photo"
        case .file: "doc"
        }
    }

    private var title: String {
        switch item.type {
        case .text: item.content.replacingOccurrences(of: "\n", with: " ")
        case .image: "图片"
        case .file: URL(fileURLWithPath: firstPath).lastPathComponent
        }
    }

    private var firstPath: String {
        item.content.components(separatedBy: "\n").first ?? ""
    }
}
