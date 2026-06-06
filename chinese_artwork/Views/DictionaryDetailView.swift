//
//  DictionaryDetailView.swift
//  chinese_artwork
//
//  單一字的詳細資訊。內容抽成 DictionaryDetailContent,
//  可放在獨立頁,也可就地(inline)顯示在清單下方。
//

import SwiftUI

/// 字的詳細資訊內容(不含導覽列設定),供獨立頁與就地顯示共用。
struct DictionaryDetailContent: View {
    let entry: DictionaryEntry
    /// 是否顯示大字標頭(分頁/書籤已顯示該字時可關閉,避免重複)。
    var showsHeader: Bool = true
    /// 大字標頭的字級。
    var headerFontSize: CGFloat = 120

    var body: some View {
        VStack(spacing: 20) {
            if showsHeader {
                header
            }

            HStack(spacing: 10) {
                InfoChip(title: "部首", value: entry.radical)
                InfoChip(title: "部首外筆畫", value: "\(entry.radicalStrokes)")
                InfoChip(title: "總筆畫", value: "\(entry.totalStrokes)", systemImage: "pencil")
            }

            VStack(alignment: .leading, spacing: 10) {
                Label("說文解字", systemImage: "book.closed")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                if entry.hasDescription {
                    Text(entry.description ?? "")
                        .font(.body)
                        .lineSpacing(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("此字暫無說文解字釋義。")
                        .font(.body)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .background(Color.secondaryBackground, in: RoundedRectangle(cornerRadius: 16))

            // 各種字體圖片(目前為 API 假圖)
            FontImageSection(character: entry.word)
                .id(entry.word)
        }
    }

    private var header: some View {
        Text(entry.word)
            .font(.system(size: headerFontSize, weight: .regular))
            .frame(maxWidth: .infinity)
            .padding(.vertical, headerFontSize > 90 ? 24 : (headerFontSize > 50 ? 16 : 10))
            .background(
                LinearGradient(
                    colors: [Color.tertiaryBackground, Color.secondaryBackground],
                    startPoint: .top, endPoint: .bottom
                ),
                in: RoundedRectangle(cornerRadius: 24)
            )
    }
}

/// 獨立詳細頁(保留供日後 push 導覽或預覽使用)。
struct DictionaryDetailView: View {
    let entry: DictionaryEntry

    var body: some View {
        ScrollView {
            DictionaryDetailContent(entry: entry)
                .padding()
        }
        .navigationTitle(entry.word)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    DictionaryDetailView(entry: DictionaryEntry(
        id: 1, word: "一", radicalId: 1, radical: "一",
        radicalStrokes: 0, totalStrokes: 1,
        description: "惟初太始，道立於一，造分天地，化成萬物。凡一之屬皆从一。弌,古文一。 〔於悉切〕"
    ))
}
