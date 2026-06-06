//
//  InfoChip.swift
//  chinese_artwork
//
//  可重用的小元件:資訊膠囊與部首篩選膠囊。
//

import SwiftUI

/// 顯示一組「標題 + 數值」的資訊膠囊,例如「總筆畫 3」。
struct InfoChip: View {
    let title: String
    let value: String
    var systemImage: String? = nil

    var body: some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption2)
            }
            Text(title)
                .foregroundStyle(.secondary)
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.thinMaterial, in: Capsule())
    }
}

/// 部首篩選用的可點選膠囊。
struct RadicalChip: View {
    let word: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(word)
                .font(.body)
                .fontWeight(isSelected ? .bold : .regular)
                .frame(minWidth: 36)
                .padding(.vertical, 6)
                .padding(.horizontal, 4)
                .background(
                    isSelected ? Color.accentColor : Color.secondaryBackground,
                    in: RoundedRectangle(cornerRadius: 10)
                )
                .foregroundStyle(isSelected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack {
            InfoChip(title: "部首", value: "一")
            InfoChip(title: "總筆畫", value: "3", systemImage: "pencil")
        }
        HStack {
            RadicalChip(word: "一", isSelected: true, action: {})
            RadicalChip(word: "丨", isSelected: false, action: {})
        }
    }
    .padding()
}
