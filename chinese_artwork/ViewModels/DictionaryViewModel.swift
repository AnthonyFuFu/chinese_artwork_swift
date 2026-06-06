//
//  DictionaryViewModel.swift
//  chinese_artwork
//
//  ViewModel 層(MVVM 核心):持有畫面狀態與查詢邏輯,
//  View 只負責呈現,不直接碰資料來源。
//

import Foundation
import Observation

/// 查字典主畫面的狀態與邏輯。
@Observable
@MainActor
final class DictionaryViewModel {

    // MARK: - 對外狀態(供 View 觀察)

    /// 載入狀態。
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private(set) var loadState: LoadState = .idle

    /// 使用者在搜尋框輸入的關鍵字。
    var searchText: String = "" {
        didSet { if oldValue != searchText { resetDetail() } }
    }

    /// 目前選取的部首編號(nil 代表未選)。
    var selectedRadicalId: Int? = nil {
        didSet { if oldValue != selectedRadicalId { resetDetail() } }
    }

    /// 在選定部首後,進一步以「部首外筆畫數」篩選(nil 代表不限)。
    var selectedStrokeFilter: Int? = nil {
        didSet { if oldValue != selectedStrokeFilter { resetDetail() } }
    }

    /// 使用者從清單點選、要在下方詳細區以分頁顯示的字(可多個,依加入順序)。
    private(set) var selectedEntries: [DictionaryEntry] = []

    /// 目前作用中的分頁(對應 selectedEntries 中某字的 id)。
    var activeEntryId: Int? = nil

    // MARK: - 私有資料

    private var allEntries: [DictionaryEntry] = []
    private let repository: DictionaryRepository

    // MARK: - 初始化

    init(repository: DictionaryRepository? = nil) {
        // 在 @MainActor 的 init 內建立預設 repository,避免預設參數在
        // nonisolated 情境下初始化而產生並行警告。
        self.repository = repository ?? LocalDictionaryRepository()
    }

    // MARK: - 載入

    /// 載入字典資料(畫面出現時呼叫一次)。
    func load() {
        guard loadState == .idle || isFailed else { return }
        loadState = .loading
        do {
            allEntries = try repository.loadEntries()
            loadState = .loaded
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    private var isFailed: Bool {
        if case .failed = loadState { return true }
        return false
    }

    // MARK: - 部首索引(供 hamburger 抽屜使用)

    /// 部首依「部首本身的筆畫數」分組,每組內依部首編號排序。
    ///
    /// 部首本身筆畫數 = 任一條目的 `總筆畫 - 部首外筆畫`(同部首皆相同)。
    var radicalGroups: [RadicalStrokeGroup] {
        var infoByRadical: [Int: RadicalInfo] = [:]
        for entry in allEntries where infoByRadical[entry.radicalId] == nil {
            let ownStrokes = max(entry.totalStrokes - entry.radicalStrokes, 0)
            infoByRadical[entry.radicalId] = RadicalInfo(
                id: entry.radicalId,
                word: entry.radical,
                strokeCount: ownStrokes
            )
        }

        let grouped = Dictionary(grouping: infoByRadical.values, by: \.strokeCount)
        return grouped
            .map { strokeCount, radicals in
                RadicalStrokeGroup(
                    strokeCount: strokeCount,
                    radicals: radicals.sorted { $0.id < $1.id }
                )
            }
            .sorted { $0.strokeCount < $1.strokeCount }
    }

    /// 目前選取的部首資訊(含部首本身筆畫數)。
    var selectedRadical: RadicalInfo? {
        guard let id = selectedRadicalId else { return nil }
        return radicalGroups.flatMap(\.radicals).first { $0.id == id }
    }

    /// 選定部首後,該部首底下所有「部首外筆畫數」選項(升冪)。
    var strokeOptions: [Int] {
        guard let id = selectedRadicalId else { return [] }
        let strokes = Set(allEntries.filter { $0.radicalId == id }.map(\.radicalStrokes))
        return strokes.sorted()
    }

    // MARK: - 多字逐字查詢

    /// 目前搜尋是否為「多個漢字」的查詢(例如輸入一個詞或一句話)。
    var isMultiCharacterQuery: Bool {
        searchKeyword.filter(\.isChineseCharacter).count >= 2
    }

    /// 將多字查詢逐字拆解,對應到字典條目(查無則 entry 為 nil),
    /// 依輸入順序、去除重複字。
    var queryCharacterBreakdown: [CharacterLookup] {
        var seen = Set<Character>()
        var result: [CharacterLookup] = []
        for ch in searchKeyword where ch.isChineseCharacter && !seen.contains(ch) {
            seen.insert(ch)
            let word = String(ch)
            let entry = allEntries.first { $0.word == word }
            result.append(CharacterLookup(character: word, entry: entry))
        }
        return result
    }

    private var searchKeyword: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - 查詢結果

    /// 依「部首 → 部首外筆畫 → 關鍵字」層層篩選後的結果。
    var filteredEntries: [DictionaryEntry] {
        var results = allEntries

        if let radicalId = selectedRadicalId {
            results = results.filter { $0.radicalId == radicalId }
        }

        if let stroke = selectedStrokeFilter {
            results = results.filter { $0.radicalStrokes == stroke }
        }

        // 原始資料已依「部首 → 部首外筆畫」排好序,維持此順序即可,
        // 不額外以總筆畫排序(避免缺資料的 0 筆畫條目被排到最前面)。
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return results }

        if keyword.count == 1 {
            let exact = results.filter { $0.word == keyword }
            if !exact.isEmpty { return exact }
        }

        return results.filter { entry in
            entry.word.contains(keyword) || (entry.description?.contains(keyword) ?? false)
        }
    }

    /// 結果統計文字。
    var resultSummary: String {
        "共 \(filteredEntries.count) 個字"
    }

    /// 是否有任何篩選或搜尋條件。
    var hasActiveFilter: Bool {
        selectedRadicalId != nil || selectedStrokeFilter != nil
            || !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - 動作

    /// 從抽屜選定部首(重設筆畫子篩選與搜尋)。
    func selectRadical(_ id: Int) {
        selectedRadicalId = id
        selectedStrokeFilter = nil
        searchText = ""
    }

    /// 點選部首外筆畫篩選(再次點選同一個可取消)。
    func toggleStroke(_ stroke: Int) {
        selectedStrokeFilter = (selectedStrokeFilter == stroke) ? nil : stroke
    }

    /// 清除所有篩選與搜尋。
    func clearFilters() {
        searchText = ""
        selectedRadicalId = nil
        selectedStrokeFilter = nil
    }

    // MARK: - 詳細區分頁(可多字)

    /// 點清單中的字:未開啟則加入分頁,並切換為作用中分頁。
    func openEntry(_ entry: DictionaryEntry) {
        if !selectedEntries.contains(entry) {
            selectedEntries.append(entry)
        }
        activeEntryId = entry.id
    }

    /// 關閉某個分頁。
    func closeEntry(_ entry: DictionaryEntry) {
        selectedEntries.removeAll { $0 == entry }
        if activeEntryId == entry.id {
            activeEntryId = selectedEntries.last?.id
        }
    }

    /// 該字是否已開啟分頁(供清單高亮)。
    func isOpen(_ entry: DictionaryEntry) -> Bool {
        selectedEntries.contains(entry)
    }

    /// 換部首/筆畫/搜尋時,清掉目前開啟的分頁。
    private func resetDetail() {
        selectedEntries = []
        activeEntryId = nil
    }
}

// MARK: - 部首索引用的輔助型別

/// 單一部首的資訊。
struct RadicalInfo: Identifiable, Hashable {
    let id: Int
    let word: String
    /// 部首本身的筆畫數。
    let strokeCount: Int
}

/// 同一「部首筆畫數」下的部首集合(供抽屜分組顯示)。
struct RadicalStrokeGroup: Identifiable {
    var id: Int { strokeCount }
    let strokeCount: Int
    let radicals: [RadicalInfo]
}

/// 多字查詢時,單一漢字的查詢結果。
struct CharacterLookup: Identifiable {
    var id: String { character }
    /// 該漢字。
    let character: String
    /// 在字典中找到的條目;nil 代表字典查無此字。
    let entry: DictionaryEntry?
}

extension Character {
    /// 是否為常用範圍內的漢字(CJK 基本區與擴充 A/B)。
    var isChineseCharacter: Bool {
        unicodeScalars.allSatisfy { scalar in
            (0x4E00...0x9FFF).contains(scalar.value)   // CJK 統一表意文字
                || (0x3400...0x4DBF).contains(scalar.value) // 擴充 A
                || (0x20000...0x2A6DF).contains(scalar.value) // 擴充 B
        }
    }
}
