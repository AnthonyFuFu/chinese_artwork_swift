//
//  ContentView.swift
//  chinese_artwork
//
//  Created by ShengHungFu on 2026/4/3.
//
//  App 根畫面,目前直接呈現查字典主畫面。
//  日後若要加入「我的最愛」「設定」等分頁,可在此放 TabView。
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        DictionaryListView()
    }
}

#Preview {
    ContentView()
}
