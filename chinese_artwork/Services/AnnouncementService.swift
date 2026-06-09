//
//  AnnouncementService.swift
//  chinese_artwork
//
//  Service 層:提供公告資料。目前為本地假資料;
//  日後接後端時,新增實作此協定的版本(例如打 News API)即可,畫面不必更動。
//

import Foundation

/// 公告資料來源協定。
protocol AnnouncementService {
    func announcements() -> [Announcement]
}

/// 本地假資料實作(示範用)。
struct SampleAnnouncementService: AnnouncementService {
    func announcements() -> [Announcement] {
        [
            Announcement(
                id: 1,
                title: "歡迎使用漢字字典",
                date: "2026-06-07",
                body: "可從左上角選單依「部首筆畫 → 部首」查字,或在上方查詢格直接輸入漢字。點清單中的字,下方會以書籤分頁顯示說文解字與各種字體。",
                isPinned: true
            ),
            Announcement(
                id: 2,
                title: "新增「各種字體」圖片",
                date: "2026-06-05",
                body: "字的詳細頁新增篆、隸、楷、草、行等書體圖片,點圖片可加入右側的收集面板。"
            ),
            Announcement(
                id: 3,
                title: "說文解字資料",
                date: "2026-06-03",
                body: "目前收錄 13,237 字、214 部首,其中 7,695 字附有說文解字釋義。"
            ),
        ]
    }
}
