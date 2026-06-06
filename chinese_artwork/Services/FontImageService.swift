//
//  FontImageService.swift
//  chinese_artwork
//
//  Service 層:提供「某字 + 某書體」的圖片來源。
//  目前是接 API 假圖(picsum 占位圖);日後要接後端真圖時,
//  只要新增一個實作此協定的版本(例如打 DictionaryPic 的 API),
//  畫面層不必更動。
//

import Foundation

/// 書體圖片來源協定。
protocol FontImageService {
    /// 可選的書體清單(對應後端 style 表的書法五體)。
    func styles() -> [FontStyle]
    /// 取得某字、某書體分類底下的所有圖片網址。
    func imageURLs(forCharacter character: String, styleId: Int) -> [URL]
}

/// 假圖實作:用 picsum 依「字 + 書體」產生穩定的占位圖,純粹串接示範用。
///
/// ⚠️ 暫時用的假資料來源。之後改接真圖:
/// 1. 新增 `RemoteFontImageService`,在 `imageURL` 回傳後端 DictionaryPic 的圖片 URL;
/// 2. 把畫面建立服務的地方換成新實作即可。
struct PlaceholderFontImageService: FontImageService {
    func styles() -> [FontStyle] {
        // 依字體演變排序,湊滿 3×3。其中 8~12 對應後端 style 表的書法五體,
        // 其餘(甲骨文/金文/大篆/小篆)為示範用,之後接真資料再對應。
        [
            FontStyle(id: 101, name: "甲骨文"),
            FontStyle(id: 102, name: "金文"),
            FontStyle(id: 103, name: "大篆"),
            FontStyle(id: 104, name: "小篆"),
            FontStyle(id: 8, name: "篆書"),
            FontStyle(id: 9, name: "隸書"),
            FontStyle(id: 10, name: "楷書"),
            FontStyle(id: 12, name: "行書"),
            FontStyle(id: 11, name: "草書"),
        ]
    }

    func imageURLs(forCharacter character: String, styleId: Int) -> [URL] {
        // 以「字的 Unicode + 書體 ID + 序號」當 seed,模擬同一書體分類下的多張圖。
        let codepoint = character.unicodeScalars.first?.value ?? 0
        return (1...4).compactMap { index in
            URL(string: "https://picsum.photos/seed/cjk-\(codepoint)-\(styleId)-\(index)/300/300")
        }
    }
}
