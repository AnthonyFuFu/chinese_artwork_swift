//
//  RadicalDrawerView.swift
//  chinese_artwork
//
//  左側抽屜選單(hamburger 展開):依「部首筆畫數」分組,
//  展開後挑選部首。選定部首後由 onSelect 回呼通知,主畫面再依該
//  部首的筆畫挑字。
//

import SwiftUI

struct RadicalDrawerView: View {
    let groups: [RadicalStrokeGroup]
    let selectedRadicalId: Int?
    /// 預設展開的部首筆畫數(讓使用者一打開就看到內容)。
    let initiallyExpandedStroke: Int?
    let onSelect: (Int) -> Void
    /// 點「公告」時呼叫。
    var onShowAnnouncements: () -> Void = {}

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 公告選項
            Button(action: onShowAnnouncements) {
                HStack(spacing: 10) {
                    Image(systemName: "megaphone")
                    Text("公告")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Divider()

            // 標題
            HStack(spacing: 8) {
                Image(systemName: "character.book.closed")
                Text("依部首查字")
                    .font(.headline)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 10)

            Text("先選筆畫數,再挑部首")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.bottom, 8)

            Divider()

            // 依筆畫數分組的部首
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(groups) { group in
                        RadicalStrokeSection(
                            group: group,
                            columns: columns,
                            selectedRadicalId: selectedRadicalId,
                            startsExpanded: group.strokeCount == initiallyExpandedStroke,
                            onSelect: onSelect
                        )
                        Divider()
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.tertiaryBackground)
    }
}

/// 單一筆畫數的可展開區段。
private struct RadicalStrokeSection: View {
    let group: RadicalStrokeGroup
    let columns: [GridItem]
    let selectedRadicalId: Int?
    let startsExpanded: Bool
    let onSelect: (Int) -> Void

    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // 整列皆可點(跨平台:不依賴 DisclosureGroup 在 macOS 只能點箭頭的行為)
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
            } label: {
                HStack {
                    Text("\(group.strokeCount) 畫")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("\(group.radicals.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(group.radicals) { radical in
                        RadicalChip(
                            word: radical.word,
                            isSelected: radical.id == selectedRadicalId
                        ) {
                            onSelect(radical.id)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .onAppear { if startsExpanded { isExpanded = true } }
    }
}

#Preview {
    RadicalDrawerView(
        groups: [
            RadicalStrokeGroup(strokeCount: 1, radicals: [
                RadicalInfo(id: 1, word: "一", strokeCount: 1),
                RadicalInfo(id: 2, word: "丨", strokeCount: 1),
                RadicalInfo(id: 3, word: "丶", strokeCount: 1),
            ]),
            RadicalStrokeGroup(strokeCount: 2, radicals: [
                RadicalInfo(id: 7, word: "二", strokeCount: 2),
                RadicalInfo(id: 9, word: "人", strokeCount: 2),
            ]),
        ],
        selectedRadicalId: 1,
        initiallyExpandedStroke: 1,
        onSelect: { _ in }
    )
    .frame(width: 300)
}
