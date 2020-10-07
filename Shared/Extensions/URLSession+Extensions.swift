//
//  URLSession+Extensions.swift
//  aqi-wtf
//
//  Created by Kyle Bashour on 10/6/20.
//

import Foundation

extension URLSession {

    enum URLSessionLoadingError: Error {
        case failedToDecode(Error)
        case unknown
    }

    private static let decoder = JSONDecoder()

    func load<T: Decodable>(_ type: T.Type, from url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let response = try Self.decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(URLSessionLoadingError.failedToDecode(error)))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(URLSessionLoadingError.unknown))
                }
            }
        }.resume()
    }
}
