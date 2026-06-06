//
//  DictionaryRepository.swift
//  chinese_artwork
//
//  Service 層:負責提供字典資料。
//  目前由 App 內建的 dictionary.json 載入(本地假資料);
//  未來要接後端 chineseArtwork 的 API 時,只需新增一個實作
//  此協定的 RemoteDictionaryRepository,ViewModel 不必更動。
//

import Foundation

/// 字典資料來源協定。抽象化資料來源(本地 / 遠端),方便日後替換。
protocol DictionaryRepository {
    /// 載入所有字典條目。
    func loadEntries() throws -> [DictionaryEntry]
}

/// 資料載入相關錯誤。
enum DictionaryRepositoryError: LocalizedError {
    case resourceNotFound(String)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .resourceNotFound(let name):
            return "找不到字典資料檔:\(name)"
        case .decodingFailed(let error):
            return "字典資料解析失敗:\(error.localizedDescription)"
        }
    }
}

/// 從 App bundle 內的 `dictionary.json` 載入資料的實作。
struct LocalDictionaryRepository: DictionaryRepository {
    private let resourceName: String
    private let bundle: Bundle

    init(resourceName: String = "dictionary", bundle: Bundle = .main) {
        self.resourceName = resourceName
        self.bundle = bundle
    }

    func loadEntries() throws -> [DictionaryEntry] {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw DictionaryRepositoryError.resourceNotFound("\(resourceName).json")
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([DictionaryEntry].self, from: data)
        } catch let error as DictionaryRepositoryError {
            throw error
        } catch {
            throw DictionaryRepositoryError.decodingFailed(error)
        }
    }
}
