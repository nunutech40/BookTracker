//
//  ImageUtils.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 17/12/25.
//
import PhotosUI
import SwiftUI

struct ImageUtils {
    // Fungsi statis, bisa dipanggil di mana aja
    static func convertSelectionToData(_ item: PhotosPickerItem) async -> Data? {
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                return data
            }
        } catch {
            print("❌ Gagal convert image: \(error)")
        }
        return nil
    }
}
