//
//  FontStyle.swift
//  chinese_artwork
//
//  書體(字體)模型,對應後端 style 表中 CAT_ID=2(字畫)的書法五體。
//

import Foundation

/// 書體,例如篆書、隸書、楷書、草書、行書。
///
/// `id` 對應後端 `style.STYLE_ID`,`name` 對應 `STYLE_NAME`。
struct FontStyle: Identifiable, Hashable {
    let id: Int
    let name: String
}
