import SwiftUI

struct TypeFilter: View {
    @Binding var selection: ClipboardItemType?

    var body: some View {
        Picker("类型", selection: $selection) {
            Text("全部").tag(ClipboardItemType?.none)
            Text("文本").tag(ClipboardItemType?.some(.text))
            Text("图片").tag(ClipboardItemType?.some(.image))
            Text("文件").tag(ClipboardItemType?.some(.file))
        }
        .pickerStyle(.segmented)
    }
}
