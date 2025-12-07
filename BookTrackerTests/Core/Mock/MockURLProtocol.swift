//
//  MockURLProtocol.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import Foundation

/**
 Class Ajaib untuk memalsukan respon jaringan.
 Tugasnya mencegat request keluar, dan langsung membalas dengan data yang kita setting.
 */
class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true // Cegat semua request
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler belum disetting!")
        }
        
        do {
            // Panggil handler buatan kita untuk dapat respon palsu
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}
