//
//  GoogleBooksService.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import Foundation

// MARK: - Data Transfer Objects (DTO)

/**
 Struktur data berikut digunakan khusus untuk **Mapping JSON** dari Google Books API.
 Berbeda dengan model internal (`Book`), struct ini hanya bertugas menangkap respon raw dari internet
 sebelum dikonversi menjadi model aplikasi.
 */

struct GoogleBookResponse: Codable {
    let items: [GoogleBookItem]?
}

struct GoogleBookItem: Codable, Identifiable {
    let id: String
    let volumeInfo: GoogleBookVolumeInfo
}

struct GoogleBookVolumeInfo: Codable {
    let title: String
    let authors: [String]?
    let pageCount: Int?
    let imageLinks: GoogleBookImageLinks?
}

struct GoogleBookImageLinks: Codable {
    let thumbnail: String?
}

// MARK: - Service Class

/**
 # GoogleBooksService (Networking Layer)
 
 **Tujuan (Why):**
 Class ini berfungsi sebagai jembatan ke dunia luar (Internet). Ia memisahkan logic pengambilan data eksternal dari logic internal aplikasi. Tugasnya murni: **Fetch -> Decode -> Return**. Tidak ada manipulasi database di sini.
 
 **Teknologi Stack:**
 - **URLSession (Shared):** Untuk melakukan HTTP Request secara asinkron.
 - **Codable (JSONDecoder):** Untuk parsing data JSON menjadi Struct Swift.
 - **Swift Concurrency (Async/Await):** Menghindari callback hell dan membuat kode networking mudah dibaca.
 
 **Algoritma Utama:**
 1. **URL Construction:** Membersihkan query string agar valid di URL.
 2. **Deserialization:** Mengubah JSON response menjadi object Swift (`GoogleBookItem`).
 3. **Image Data Conversion:** Mengunduh gambar dari URL dan mengubahnya menjadi binary `Data` (Blob) untuk disimpan offline.
 */
final class GoogleBooksService {
    
    // MARK: - Search Feature
    
    /**
     Mencari buku berdasarkan kata kunci (query) menggunakan Google Books API.
     
     **Endpoint:**
     `GET https://www.googleapis.com/books/v1/volumes?q={query}`
     
     **Algoritma:**
     1. **Sanitasi Input:** Mengubah spasi atau karakter spesial di query menjadi format URL-safe (Percent Encoding).
     2. **Request:** Melakukan HTTP GET request ke server Google.
     3. **Decoding:** Mencoba memecah JSON response ke dalam struktur `GoogleBookResponse`.
     4. **Fail-safe:** Jika items kosong atau error, return array kosong (jangan crash).
     
     - Parameter query: Judul buku, penulis, atau ISBN yang dicari user.
     - Returns: Array `[GoogleBookItem]` yang berisi hasil pencarian raw.
     */
    func searchBooks(query: String) async throws -> [GoogleBookItem] {
        // 1. URL Encoding (misal: "Harry Potter" -> "Harry%20Potter")
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=\(encodedQuery)") else {
            return []
        }
        
        // 2. Network Call
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // 3. JSON Decoding
        let decodedResponse = try JSONDecoder().decode(GoogleBookResponse.self, from: data)
        return decodedResponse.items ?? []
    }
    
    // MARK: - Image Handling
    
    /**
     Mengunduh gambar cover buku dan mengkonversinya menjadi binary Data.
     
     **Penting:**
     Google Books API sering memberikan URL gambar dengan protokol `http://`.
     iOS memblokir `http` secara default (ATS Policy). Fungsi ini otomatis mengupgrade ke `https://`.
     
     **Tujuan:**
     Kita menyimpan `Data` (bukan URL) agar cover buku bisa muncul saat user **Offline**.
     
     - Parameter urlString: URL gambar (thumbnail) dari API response.
     - Returns: Binary `Data` gambar jika berhasil, atau `nil` jika gagal.
     */
    func downloadCoverImage(from urlString: String?) async -> Data? {
        // 1. Protocol Upgrade (HTTP -> HTTPS) & URL Validation
        guard let urlString = urlString?.replacingOccurrences(of: "http://", with: "https://"),
              let url = URL(string: urlString) else { return nil }
        
        do {
            // 2. Download Binary Data
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            return nil
        }
    }
}
