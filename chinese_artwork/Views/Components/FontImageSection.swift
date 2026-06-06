//
//  FontImageSection.swift
//  chinese_artwork
//
//  詳細區下方的「各種字體」區塊:
//  上方 3×3 書體選擇按鈕;選定某書體後,下方才顯示該書體分類的圖片。
//  目前圖片來自 PlaceholderFontImageService 的假圖。
//

import SwiftUI

struct FontImageSection: View {
    let character: String
    var service: FontImageService = PlaceholderFontImageService()
    /// 點某張圖時的回呼(用於收集到右側面板)。
    var onPickImage: (CollectedImage) -> Void = { _ in }

    @State private var selectedStyleId: Int?

    private let buttonColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
    private let imageColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("各種字體", systemImage: "photo.on.rectangle.angled")
                .font(.headline)
                .foregroundStyle(.secondary)

            // 3×3 書體選擇按鈕
            LazyVGrid(columns: buttonColumns, spacing: 8) {
                ForEach(service.styles()) { style in
                    styleButton(style)
                }
            }

            Divider()

            // 選定書體後才顯示該分類的圖片
            imageArea
        }
        .padding()
        .background(Color.secondaryBackground, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 書體按鈕

    private func styleButton(_ style: FontStyle) -> some View {
        let isOn = style.id == selectedStyleId
        return Button {
            selectedStyleId = style.id
        } label: {
            Text(style.name)
                .font(.subheadline)
                .fontWeight(isOn ? .bold : .regular)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    isOn ? Color.accentColor : Color.tertiaryBackground,
                    in: RoundedRectangle(cornerRadius: 10)
                )
                .foregroundStyle(isOn ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 圖片區

    @ViewBuilder
    private var imageArea: some View {
        if let styleId = selectedStyleId {
            let urls = service.imageURLs(forCharacter: character, styleId: styleId)
            let styleName = service.styles().first { $0.id == styleId }?.name ?? ""

            Text("「\(character)」\(styleName)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            LazyVGrid(columns: imageColumns, spacing: 8) {
                ForEach(urls, id: \.self) { url in
                    Button {
                        onPickImage(CollectedImage(character: character, styleName: styleName, url: url))
                    } label: {
                        fontImage(url)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("點圖片可加入右側收集")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        } else {
            Text("選擇上方書體以顯示圖片")
                .font(.footnote)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, minHeight: 80)
        }
    }

    private func fontImage(_ url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                Image(systemName: "photo")
                    .foregroundStyle(.tertiary)
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .background(Color.tertiaryBackground, in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    ScrollView {
        FontImageSection(character: "仁")
            .padding()
    }
}
