//
//  DictionaryRowView.swift
//  chinese_artwork
//
//  列表中單一字的列。
//

import SwiftUI

struct DictionaryRowView: View {
    let entry: DictionaryEntry

    var body: some View {
        HStack(spacing: 14) {
            // 漢字大字
            Text(entry.word)
                .font(.system(size: 40))
                .frame(width: 56, height: 56)
                .background(Color.secondaryBackground, in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("部首 \(entry.radical)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("總筆畫 \(entry.totalStrokes)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text(entry.descriptionPreview)
                    .font(.footnote)
                    .foregroundStyle(entry.hasDescription ? .primary : .tertiary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}

#Preview {
    List {
        DictionaryRowView(entry: DictionaryEntry(
            id: 1, word: "一", radicalId: 1, radical: "一",
            radicalStrokes: 0, totalStrokes: 1,
            description: "惟初太始，道立於一，造分天地，化成萬物。凡一之屬皆从一。"
        ))
        DictionaryRowView(entry: DictionaryEntry(
            id: 6, word: "万", radicalId: 1, radical: "一",
            radicalStrokes: 2, totalStrokes: 3, description: nil
        ))
    }
}
