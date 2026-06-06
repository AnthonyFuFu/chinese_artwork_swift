//
//  Color+Theme.swift
//  chinese_artwork
//
//  跨平台語意色:iOS 用 UIColor 的系統背景色,macOS 用 NSColor 對應色,
//  讓同一份 SwiftUI 程式碼在 iOS / iPadOS / macOS 都能編譯與顯示。
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    /// 次要背景色(卡片、列表項底色)。
    static var secondaryBackground: Color {
        #if canImport(UIKit)
        Color(uiColor: .secondarySystemBackground)
        #elseif canImport(AppKit)
        Color(nsColor: .controlBackgroundColor)
        #else
        Color.gray.opacity(0.15)
        #endif
    }

    /// 第三層背景色(漸層上緣等)。
    static var tertiaryBackground: Color {
        #if canImport(UIKit)
        Color(uiColor: .tertiarySystemBackground)
        #elseif canImport(AppKit)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color.gray.opacity(0.1)
        #endif
    }
}
