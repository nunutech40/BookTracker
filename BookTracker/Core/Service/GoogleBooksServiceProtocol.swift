//
//  GoogleBooksServiceProtocol.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 18/12/25.
//

import Foundation

protocol GoogleBooksServiceProtocol {
    func searchBooks(query: String) async throws -> [GoogleBookItem]
    func downloadCoverImage(from urlString: String?) async -> Data?
}
