//
//  AnnouncementView.swift
//  chinese_artwork
//
//  公告頁面。以 sheet 呈現,列出所有公告。
//

import SwiftUI

struct AnnouncementView: View {
    var service: AnnouncementService = SampleAnnouncementService()

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(sortedAnnouncements) { item in
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        if item.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                        Text(item.title)
                            .font(.headline)
                        Spacer()
                        Text(item.date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(item.body)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("公告")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }

    /// 置頂優先,其餘維持原順序。
    private var sortedAnnouncements: [Announcement] {
        let all = service.announcements()
        return all.filter(\.isPinned) + all.filter { !$0.isPinned }
    }
}

#Preview {
    AnnouncementView()
}
