//
//  Errors.swift
//  OOTD-swift
//
//  Created by Jules on 9/3/25.
//

import Foundation

enum APIError: LocalizedError {
    case unauthorized
    case badRequest(String)
    case notFound
    case processingFailed(String)
    case serverError

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Please sign in again"
        case .badRequest(let message):
            return "Invalid request: \(message)"
        case .notFound:
            return "No data found"
        case .processingFailed(let message):
            return "Processing failed: \(message)"
        case .serverError:
            return "Server error. Please try again."
        }
    }
}
