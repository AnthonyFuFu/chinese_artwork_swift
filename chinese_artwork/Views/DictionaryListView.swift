//
//  DictionaryListView.swift
//  chinese_artwork
//
//  查字典主畫面:
//  最上方一列 = 左 hamburger + 右查詢格(同一水平線);
//  下方 = 查詢結果的小字清單(可點);
//  點某字 → 就地在下方顯示該字的資訊。
//

import SwiftUI

struct DictionaryListView: View {
    @State private var viewModel = DictionaryViewModel()
    @State private var isDrawerOpen = false

    private let drawerWidth: CGFloat = 300
    private let gridColumns = [GridItem(.adaptive(minimum: 52), spacing: 8)]

    var body: some View {
        ZStack(alignment: .leading) {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    // 主要區(查字 + 詳細)
                    VStack(spacing: 0) {
                        topBar
                        Divider()

                        switch viewModel.loadState {
                        case .idle, .loading:
                            ProgressView("載入字典中…")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case .failed(let message):
                            errorView(message)
                        case .loaded:
                            content
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // 右側收集面板(約 1/5 寬):有收集到圖片才顯示,清空後收起
                    if !viewModel.collectedImages.isEmpty {
                        Divider()
                        collectionPanel
                            .frame(width: geo.size.width * 0.2)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: viewModel.collectedImages.isEmpty)
            }

            if isDrawerOpen {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { closeDrawer() }
                    .transition(.opacity)

                RadicalDrawerView(
                    groups: viewModel.radicalGroups,
                    selectedRadicalId: viewModel.selectedRadicalId,
                    initiallyExpandedStroke: viewModel.selectedRadical?.strokeCount ?? 1,
                    onSelect: { id in
                        viewModel.selectRadical(id)
                        closeDrawer()
                    }
                )
                .frame(width: drawerWidth)
                .transition(.move(edge: .leading))
                .shadow(radius: 8)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isDrawerOpen)
        .onAppear { viewModel.load() }
    }

    // MARK: - 最上方一列:hamburger + 查詢格

    private var topBar: some View {
        HStack(spacing: 12) {
            Button {
                isDrawerOpen.toggle()
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
            }
            .accessibilityLabel("部首選單")

            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("輸入漢字或關鍵字", text: $viewModel.searchText)
                    .autocorrectionDisabled()
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(Color.secondaryBackground, in: Capsule())
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    // MARK: - 內容

    @ViewBuilder
    private var content: some View {
        if viewModel.hasActiveFilter {
            resultArea
        } else {
            welcomeState
        }
    }

    // MARK: - 結果區:小字清單 + 就地詳細

    @ViewBuilder
    private var resultArea: some View {
        VStack(spacing: 0) {
            filterRow

            if hasResults {
                charGrid
                    .frame(maxHeight: viewModel.selectedEntries.isEmpty ? .infinity : 140)

                if !viewModel.selectedEntries.isEmpty {
                    Divider()
                    detailTabs
                }
            } else {
                ContentUnavailableView {
                    Label("查無結果", systemImage: "magnifyingglass")
                } description: {
                    Text("試試左上角的部首選單,或換個關鍵字。")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    /// 精簡篩選列:部首 / 筆畫 下拉 + 結果數 + 清除,只佔一行。
    private var filterRow: some View {
        HStack(spacing: 8) {
            if viewModel.selectedRadical != nil {
                // 部首:點開部首抽屜(214 部用分組抽屜較好選)
                Button {
                    isDrawerOpen = true
                } label: {
                    DropdownChip(title: "部首", value: viewModel.selectedRadical?.word ?? "全部")
                }
                .buttonStyle(.plain)

                // 筆畫:真正的下拉選單
                Menu {
                    Button {
                        viewModel.selectedStrokeFilter = nil
                    } label: {
                        strokeMenuLabel("全部", isOn: viewModel.selectedStrokeFilter == nil)
                    }
                    ForEach(viewModel.strokeOptions, id: \.self) { stroke in
                        Button {
                            viewModel.selectedStrokeFilter = stroke
                        } label: {
                            strokeMenuLabel("\(stroke) 畫", isOn: viewModel.selectedStrokeFilter == stroke)
                        }
                    }
                } label: {
                    DropdownChip(
                        title: "筆畫",
                        value: viewModel.selectedStrokeFilter.map { "\($0) 畫" } ?? "全部"
                    )
                }
            }

            Spacer()

            Text(summaryText)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Button("清除") { viewModel.clearFilters() }
                .font(.caption2)
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private func strokeMenuLabel(_ title: String, isOn: Bool) -> some View {
        if isOn {
            Label(title, systemImage: "checkmark")
        } else {
            Text(title)
        }
    }

    /// 小字、可點的結果清單(網格)。
    private var charGrid: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 8) {
                if viewModel.isMultiCharacterQuery {
                    ForEach(viewModel.queryCharacterBreakdown) { item in
                        CharCell(
                            character: item.character,
                            isSelected: item.entry.map { viewModel.isOpen($0) } ?? false,
                            isEnabled: item.entry != nil
                        ) {
                            if let entry = item.entry { viewModel.openEntry(entry) }
                        }
                    }
                } else {
                    ForEach(viewModel.filteredEntries) { entry in
                        CharCell(
                            character: entry.word,
                            isSelected: viewModel.isOpen(entry),
                            isEnabled: true
                        ) {
                            viewModel.openEntry(entry)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    // MARK: - 詳細區:多字標籤 + 可滑動分頁

    private var detailTabs: some View {
        VStack(spacing: 0) {
            // 書籤標籤列:每片像書本書籤凸出,作用中那片與下方內容卡相連
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(viewModel.selectedEntries) { entry in
                        bookmarkTab(entry)
                    }
                }
                .padding(.horizontal, 12)
            }

            // 內容卡
            #if os(iOS)
            // iOS:可左右滑動的分頁(.page 會隱藏系統分頁列)
            TabView(selection: $viewModel.activeEntryId) {
                ForEach(viewModel.selectedEntries) { entry in
                    ScrollView {
                        DictionaryDetailContent(
                            entry: entry,
                            showsHeader: false,
                            onPickImage: { viewModel.collectImage($0) }
                        )
                        .padding()
                    }
                    .tag(Optional(entry.id))
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .background(Color.secondaryBackground)
            #else
            // macOS:沒有 .page 樣式,直接顯示作用中那頁(用上方書籤切換)
            ScrollView {
                if let entry = viewModel.activeEntry {
                    DictionaryDetailContent(
                        entry: entry,
                        showsHeader: false,
                        onPickImage: { viewModel.collectImage($0) }
                    )
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.secondaryBackground)
            #endif
        }
    }

    /// 書本書籤外觀的分頁標籤:上緣圓角、凸出,作用中與內容卡同色相連。
    private func bookmarkTab(_ entry: DictionaryEntry) -> some View {
        let isActive = entry.id == viewModel.activeEntryId
        return Button {
            viewModel.activeEntryId = entry.id
        } label: {
            HStack(spacing: 6) {
                Text(entry.word)
                    .font(.subheadline)
                    .fontWeight(isActive ? .bold : .regular)
                Button {
                    viewModel.closeEntry(entry)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.top, isActive ? 10 : 6)
            .padding(.bottom, isActive ? 12 : 8)
            .background(
                UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12)
                    .fill(isActive ? Color.secondaryBackground : Color.gray.opacity(0.22))
                    .shadow(color: .black.opacity(isActive ? 0.12 : 0), radius: 2, y: -1)
            )
            .foregroundStyle(isActive ? Color.primary : Color.secondary)
        }
        .buttonStyle(.plain)
    }

    private var hasResults: Bool {
        viewModel.isMultiCharacterQuery
            ? !viewModel.queryCharacterBreakdown.isEmpty
            : !viewModel.filteredEntries.isEmpty
    }

    private var summaryText: String {
        viewModel.isMultiCharacterQuery
            ? "逐字查詢:\(viewModel.queryCharacterBreakdown.count) 個字"
            : viewModel.resultSummary
    }

    // MARK: - 起始引導畫面

    private var welcomeState: some View {
        ContentUnavailableView {
            Label("開始查字", systemImage: "character.book.closed")
        } description: {
            Text("點左上角的選單,先選筆畫數再挑部首;\n或在上方查詢格直接輸入漢字。\n清單中的字點一下,就會在下方顯示資訊。")
        } actions: {
            Button {
                isDrawerOpen = true
            } label: {
                Label("選擇部首", systemImage: "line.3.horizontal")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - 右側收集面板

    private var collectionPanel: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "tray.full")
                    .font(.caption)
                Text("收集")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(viewModel.collectedImages) { image in
                        collectedThumb(image)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.bottom, 8)
            }

            Button {
                viewModel.clearCollected()
            } label: {
                Label("清空", systemImage: "trash")
                    .font(.caption2)
            }
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.secondaryBackground)
    }

    private func collectedThumb(_ image: CollectedImage) -> some View {
        VStack(spacing: 2) {
            AsyncImage(url: image.url) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                case .empty:
                    ProgressView()
                default:
                    Image(systemName: "photo").foregroundStyle(.tertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(alignment: .topTrailing) {
                Button {
                    viewModel.removeCollected(image)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.white, .black.opacity(0.5))
                }
                .buttonStyle(.plain)
                .padding(3)
            }

            Text("\(image.character)·\(image.styleName)")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    // MARK: - 錯誤

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("載入失敗", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("重試") { viewModel.load() }
                .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - 動作

    private func closeDrawer() {
        isDrawerOpen = false
    }
}

/// 小字、可點的結果格子。
private struct CharCell: View {
    let character: String
    let isSelected: Bool
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(character)
                .font(.system(size: 24))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    isSelected ? Color.accentColor : Color.secondaryBackground,
                    in: RoundedRectangle(cornerRadius: 10)
                )
                .foregroundStyle(isSelected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.35)
        .disabled(!isEnabled)
    }
}

/// 精簡的下拉式篩選膠囊:標題 + 目前值 + 向下箭頭。
private struct DropdownChip: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .foregroundStyle(.secondary)
            Text(value)
                .fontWeight(.semibold)
            Image(systemName: "chevron.down")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Color.secondaryBackground, in: Capsule())
        .foregroundStyle(.primary)
    }
}

#Preview {
    DictionaryListView()
}
