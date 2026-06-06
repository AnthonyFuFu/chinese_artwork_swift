//
//  CollectedImage.swift
//  chinese_artwork
//
//  被點選收集起來的單張字體圖片(僅存在記憶體,不寫入暫存或資料庫)。
//

import Foundation

/// 收集面板中的一張圖:記錄是哪個字、哪個書體、哪張圖。
struct CollectedImage: Identifiable, Hashable {
    var id: String { url.absoluteString }
    let character: String
    let styleName: String
    let url: URL
}
