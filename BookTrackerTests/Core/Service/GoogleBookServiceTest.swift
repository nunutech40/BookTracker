//
//  GoogleBookServiceTest.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import XCTest
@testable import BookTracker

/**
 # Unit Test Networking (Mocking Strategy)
 
 **Teori:**
 Mengetes networking itu bukan mengetes "Apakah server Google jalan?",
 tapi mengetes **"Apakah aplikasi gue bisa memproses jawaban server dengan benar?"**
 
 **Apa yang dites:**
 1. **URL Construction:** Apakah query spasi berubah jadi `%20`?
 2. **Decoding:** Apakah JSON ruwet dari Google sukses jadi struct `GoogleBookItem`?
 3. **Error Handling:** Kalau data kosong, apakah crash atau return array kosong?
 */
final class GoogleBooksServiceTests: XCTestCase {
    
    var service: GoogleBooksService!
    var session: URLSession!
    
    override func setUp() {
        // Setup "Internet Palsu"
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self] // Suruh session pake protocol palsu kita
        session = URLSession(configuration: config)
        
        // Masukkan session palsu ke Service
        service = GoogleBooksService(session: session)
    }
    
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        service = nil
        session = nil
    }
    
    // MARK: - Test Parsing Success
    
    func testSearchBooks_SuccessParsing() async throws {
        // GIVEN: Siapkan JSON Palsu (Ini ceritanya jawaban Google)
        let jsonString = """
        {
            "items": [
                {
                    "id": "12345",
                    "volumeInfo": {
                        "title": "Belajar Swift",
                        "authors": ["Nunu"],
                        "pageCount": 300,
                        "imageLinks": {
                            "thumbnail": "http://img.com/a.jpg"
                        }
                    }
                }
            ]
        }
        """
        let mockData = jsonString.data(using: .utf8)!
        
        // Setting Mock: "Kalau ada request, balas dengan JSON ini & Status 200 OK"
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockData)
        }
        
        // WHEN: Panggil fungsi aslinya
        let result = try await service.searchBooks(query: "Belajar Swift")
        
        // THEN: Cek hasilnya
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.volumeInfo.title, "Belajar Swift")
        XCTAssertEqual(result.first?.volumeInfo.authors?.first, "Nunu")
    }
    
    // MARK: - Test URL Encoding
    func testSearchBooks_UrlEncoding() async throws {
        // GIVEN: JSON Kosong gak masalah, kita mau cek URL-nya
        let mockData = "{}".data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            // CEK URL DISINI: Apakah spasi berubah jadi %20?
            let urlString = request.url?.absoluteString
            XCTAssertTrue(urlString!.contains("Harry%20Potter"), "Query spasi harus di-encode")
            
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockData)
        }
        
        // WHEN: Input query dengan spasi
        _ = try await service.searchBooks(query: "Harry Potter")
    }
    
    // MARK: - Test Empty/Error Response
    
    func testSearchBooks_EmptyResponse() async throws {
        // GIVEN: JSON tanpa "items" (misal buku gak ketemu)
        let jsonString = "{}" // Kosong
        let mockData = jsonString.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockData)
        }
        
        // WHEN
        let result = try await service.searchBooks(query: "Hantu")
        
        // THEN
        XCTAssertTrue(result.isEmpty, "Harusnya return array kosong, bukan crash")
    }
}
