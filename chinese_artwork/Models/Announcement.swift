//
//  Announcement.swift
//  chinese_artwork
//
//  公告模型(目前為本地假資料,日後可對應後端 News)。
//

import Foundation

/// 一則公告。
struct Announcement: Identifiable, Hashable {
    let id: Int
    let title: String
    /// 顯示用日期字串,例如 "2026-06-07"。
    let date: String
    let body: String
    /// 是否置頂。
    var isPinned: Bool = false
}
