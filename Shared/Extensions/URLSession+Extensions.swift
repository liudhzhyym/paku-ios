//
//  URLSession+Extensions.swift
//  Paku
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

    @discardableResult
    func load<T: Decodable>(_ type: T.Type, from url: URL, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let response = try Self.decoder.decode(T.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(URLSessionLoadingError.failedToDecode(error)))
                }
            } else {
                completion(.failure(URLSessionLoadingError.unknown))
            }
        }

        task.resume()
        return task
    }
}
