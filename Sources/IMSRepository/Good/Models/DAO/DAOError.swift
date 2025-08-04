//
//  DAOError.swift
//  server
//
//  Created by Mario Rúa on 26/07/25.
//

enum DAOError: Error, Equatable {
    case notFound(String)
    case savingError(String)
}
