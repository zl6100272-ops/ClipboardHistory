# Clipboard History

**macOS 原生剪贴板历史管理工具**，灵感来自 Windows 的 `Win+V`。

菜单栏常驻 → 按 `⌘⇧V` → 光标位置弹出浮动窗口 → 点击即粘贴。

![demo](https://img.shields.io/badge/platform-macOS_13.5%2B-blue)
![language](https://img.shields.io/badge/Swift-5.9-orange)
![license](https://img.shields.io/badge/license-MIT-green)

---

## ✨ 功能

| 功能 | 说明 |
|:----|:-----|
| 🧠 **智能历史** | 自动保存最近复制的 **100条** 记录 |
| 📝 **文本** | 纯文本内容，显示前2行摘要 |
| 🖼️ **图片** | 自动生成 200x200 缩略图展示 |
| 📁 **文件** | 记录文件引用路径，显示文件图标 |
| ⌨️ **快捷键** | 默认 `⌘⇧V` 弹出历史窗口 |
| 🔍 **搜索** | 输入即搜索，过滤文本和文件名 |
| 🏷️ **类型过滤** | 全部/文本/图片/文件 一键切换 |
| 🖱️ **点击即粘贴** | 选中后自动写入剪贴板并模拟 `⌘V` |
| 🕶️ **隐私模式** | 菜单栏一键暂停记录，图标变灰 |
| ⚙️ **设置** | 自定义快捷键、开机自启动 |

## 📸 截图

_（等待截图中）_

## 🚀 安装

### 方式一：从源码构建

```bash
git clone https://github.com/zl6100272-ops/ClipboardHistory.git
cd ClipboardHistory
open Package.swift
```

在 Xcode 中：
1. 选择 `ClipboardHistory` target
2. **Build Settings → Info.plist File** 设置为 `ClipboardHistory/Info.plist`
3. 点击 Run (`⌘R`)

### 方式二：直接下载 Release

_（等待发布 .dmg 安装包）_

## 🎮 使用指南

### 第一次启动
1. 应用启动后，会自动弹出 **辅助功能权限** 请求
2. 前往 **系统设置 → 隐私与安全性 → 辅助功能**，勾选 `ClipboardHistory`
3. 按 `⌘⇧V` 测试弹出窗口

### 日常使用

```
⌘C 复制 → 按 ⌘⇧V → 看到历史列表 → 点击要粘贴的项 → 自动粘贴
```

- **菜单栏图标** ✂️：点击可切换隐私模式/退出
- **搜索框**：输入关键词过滤历史记录
- **类型过滤**：全部/文本/图片/文件 分段切换
- **隐私模式**：菜单栏点击切换，图标变灰表示已暂停

### 自定义设置

打开 **ClipboardHistory → Settings**（或从菜单栏进入）：

- 修改历史窗口快捷键
- 修改隐私模式快捷键
- 开关开机自启动
- 暂停/恢复记录

## 🏗️ 项目结构

```
ClipboardHistory/
├── Package.swift                  # SPM 配置
├── ClipboardHistory/
│   ├── Info.plist                 # LSUIElement=true
│   ├── App/
│   │   ├── ClipboardHistoryApp.swift   # @main 入口
│   │   └── AppDelegate.swift           # 生命周期
│   ├── MenuBar/
│   │   └── MenuBarManager.swift        # 菜单栏图标
│   ├── Monitor/
│   │   ├── ClipboardMonitor.swift       # 0.5s轮询
│   │   └── ClipboardItem.swift         # 数据模型
│   ├── Storage/
│   │   ├── DatabaseManager.swift        # SQLite CRUD
│   │   └── FileManager.swift           # 图片缓存
│   ├── UI/
│   │   ├── FloatingWindow.swift         # 浮动窗口
│   │   ├── ContentView.swift            # 网格列表
│   │   ├── GridItemView.swift           # 网格项
│   │   ├── SearchBar.swift              # 搜索栏
│   │   ├── TypeFilter.swift             # 类型过滤
│   │   ├── ThumbnailCache.swift         # 缩略图缓存
│   │   └── SettingsView.swift           # 设置界面
│   ├── Paste/
│   │   └── PasteManager.swift           # 模拟粘贴
│   ├── Shortcut/
│   │   └── ShortcutManager.swift        # 全局快捷键
│   └── Assets.xcassets/                 # 图标资源
└── README.md
```

## 🔧 技术栈

| 技术 | 用途 |
|:----|:-----|
| **Swift 5.9** | 开发语言 |
| **SwiftUI** | UI 框架 |
| **AppKit** | 菜单栏、窗口、剪贴板 |
| **GRDB** | SQLite 数据库 |
| **Carbon** | 全局快捷键注册 |
| **CGEvent** | 模拟键盘粘贴事件 |

## 📦 依赖

- [GRDB.swift](https://github.com/groue/GRDB.swift) — SQLite 数据库

## ⚠️ 注意事项

- **需要辅助功能权限**：用于全局快捷键和模拟粘贴
- **App Sandbox 已关闭**：如需开启需添加文件访问权限
- **自启动**：使用 `SMAppService`，需要签名后才生效
- **最低系统**：macOS 13.5 (Ventura)

## 📄 License

MIT

## 🙏 致谢

- 参考 Windows `Win+V` 交互设计
- 参考 [ClipPocket](https://github.com/Dhahd/ClipPocket) 功能设计
- 参考 [Qopy](https://github.com/0PandaDEV/Qopy) 跨平台方案
