import SwiftUI

struct ContentView: View {
    let database: DatabaseManager
    let onSelect: (ClipboardItem) -> Void

    @State private var query = ""
    @State private var filter: ClipboardItemType?
    @State private var items: [ClipboardItem] = []
    @State private var errorMessage: String?

    private let columns = [
        GridItem(.adaptive(minimum: 132, maximum: 190), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 12) {
            SearchBar(query: $query)
            TypeFilter(selection: $filter)

            if let errorMessage {
                Text(errorMessage)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if items.isEmpty {
                Text("暂无剪贴板记录")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(items) { item in
                            Button {
                                onSelect(item)
                            } label: {
                                GridItemView(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
        }
        .padding(14)
        .frame(width: 600, height: 400)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .onAppear(perform: load)
        .onChange(of: query) { _ in load() }
        .onChange(of: filter) { _ in load() }
    }

    private func load() {
        do {
            items = try database.latest(search: query, type: filter)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
