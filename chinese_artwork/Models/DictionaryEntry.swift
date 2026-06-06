//
//  DictionaryEntry.swift
//  chinese_artwork
//
//  Model 層:對應後端 chineseArtwork 的 Dictionary 資料表。
//  欄位來自 radical_characters CSV(部首編號、筆畫、漢字、總筆畫、說文解字)。
//

import Foundation

/// 單一漢字的字典條目。
///
/// 對應後端 `Models/Dictionary.cs`:
/// - `word` ⇄ `DictWord`
/// - `radicalId` ⇄ `RadicalId`
/// - `radicalStrokes` ⇄ `DictStrokes`(部首外筆畫)
/// - `totalStrokes` ⇄ `DictTatolStrokes`(總筆畫)
/// - `description` ⇄ `DictDescription`(說文解字釋義)
struct DictionaryEntry: Identifiable, Codable, Hashable {
    let id: Int
    /// 漢字本身,例如「一」。
    let word: String
    /// 所屬部首編號(康熙 214 部)。
    let radicalId: Int
    /// 部首字,例如「一」。
    let radical: String
    /// 部首外筆畫數。
    let radicalStrokes: Int
    /// 總筆畫數。
    let totalStrokes: Int
    /// 說文解字釋義,可能為空。
    let description: String?
}

extension DictionaryEntry {
    /// 是否有釋義內容可顯示。
    var hasDescription: Bool {
        guard let description else { return false }
        return !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 預覽用的精簡釋義(列表用,截斷過長文字)。
    var descriptionPreview: String {
        guard let description, hasDescription else { return "暫無釋義" }
        let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= 40 { return trimmed }
        return String(trimmed.prefix(40)) + "…"
    }
}
