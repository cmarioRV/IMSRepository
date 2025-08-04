//
//  GoodProviderDAO.swift
//  server
//
//  Created by Mario Rúa on 26/07/25.
//
import Fluent

public protocol GoodProviderDAOProtocol: Sendable {
    func findAll(on database: any Database) async throws -> [GoodProviderModel]
    func findBy(goodId: UUID, providerId: UUID, on database: any Database) async throws -> GoodProviderModel?
    func findBy(goodId: UUID, on database: any Database) async throws -> [GoodProviderModel]
    func findBy(providerId: UUID, on database: any Database) async throws -> [GoodProviderModel]
    @discardableResult
    func create(goodId: UUID, providerId: UUID, on database: any Database) async throws -> GoodProviderModel
    func update(_ id: UUID, with userId: UUID?, providerId: UUID?, on database: any Database) async throws -> GoodProviderModel
    func delete(_ id: UUID, on database: any Database) async throws -> Bool
}

public struct GoodProviderDAO: GoodProviderDAOProtocol {
    public init() {}
    
    public func findAll(on database: any FluentKit.Database) async throws -> [GoodProviderModel] {
        let models = try await GoodProviderModel.query(on: database).all()
        return models
    }
    
    public func findBy(goodId: UUID, providerId: UUID, on database: any Database) async throws -> GoodProviderModel? {
        try await GoodProviderModel.query(on: database)
            .filter(\.$good.$id, .equal, goodId)
            .filter(\.$provider.$id, .equal, providerId)
            .first()
    }
    
    public func findBy(goodId: UUID, on database: any FluentKit.Database) async throws -> [GoodProviderModel] {
        try await GoodProviderModel.query(on: database)
            .filter(\.$good.$id, .equal, goodId)
            .all()
    }
    
    public func findBy(providerId: UUID, on database: any FluentKit.Database) async throws -> [GoodProviderModel] {
        try await GoodProviderModel.query(on: database)
            .filter(\.$provider.$id, .equal, providerId)
            .all()
    }
    
    public func create(goodId: UUID, providerId: UUID, on database: any FluentKit.Database) async throws -> GoodProviderModel {
        let model = GoodProviderModel(goodId: goodId, providerId: providerId)
        try await model.save(on: database)
        return model
    }
    
    public func update(_ id: UUID, with userId: UUID?, providerId: UUID?, on database: any FluentKit.Database) async throws -> GoodProviderModel {
        guard let model = try await GoodProviderModel.find(id, on: database) else {
            throw DAOError.notFound("GoodProvider pivot not found")
        }
        
        return model
    }
    
    public func delete(_ id: UUID, on database: any FluentKit.Database) async throws -> Bool {
        guard let model = try await GoodProviderModel.find(id, on: database) else {
            return false
        }
        
        try await model.delete(on: database)
        return true
    }
    
}
