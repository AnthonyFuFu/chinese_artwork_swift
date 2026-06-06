# 漢字字典 chinese_artwork

iOS 漢字查字典 App,以 SwiftUI + MVVM 架構開發。可依部首/筆畫或關鍵字查字,
點字後以「書籤分頁」顯示該字的說文解字釋義與各種書體圖片。

## 環境需求

- Xcode 26.x（含 iOS 26.x SDK 與模擬器執行環境）
- iOS 部署目標：26.4

## 開始開發

```bash
git clone https://github.com/AnthonyFuFu/chinese_artwork_swift.git
cd chinese_artwork_swift
open chinese_artwork.xcodeproj
```

在 Xcode 選一個 iPhone 模擬器後按 ▶︎ 即可執行。
專案使用 Xcode 的 file-system synchronized group，資料夾內新增的檔案會自動納入編譯。

## 專案結構（MVVM）

```
chinese_artwork/
├── Models/         # 資料模型(DictionaryEntry、FontStyle)
├── ViewModels/     # DictionaryViewModel(查詢/篩選/分頁狀態與邏輯)
├── Views/          # 畫面與元件(清單、書籤分頁、各種字體區塊)
├── Services/       # 資料來源(DictionaryRepository、FontImageService),以協定抽象,方便日後接後端
└── Resources/      # dictionary.json(內建字典假資料)
```

## 資料來源

- **字典內容**：目前使用內建的 `Resources/dictionary.json`（13,237 字 / 214 部首 / 說文解字）。
- **各種字體圖片**：目前為 API 假圖（placeholder）；日後改接後端真圖時，新增一個
  實作 `FontImageService` 協定的版本回傳真實圖片 URL 即可,畫面不必更動。

> 後端(C# ASP.NET Core）為另一個獨立專案,不包含在此儲存庫中。
