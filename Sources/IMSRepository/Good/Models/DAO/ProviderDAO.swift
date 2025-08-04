//
//  ProviderDAO.swift
//  server
//
//  Created by Mario Rúa on 23/07/25.
//
import Fluent
import IMSDomain

public protocol ProviderDAOProtocol: Sendable {
    func findAll(on database: any Database) async throws -> [Provider]
    func findById(_ id: UUID, on database: any Database) async throws -> Provider?
    func findByName(_ name: String, on database: any Database) async throws -> Provider?
    func create(_ provider: Provider, on database: any Database) async throws -> Provider
    func update(_ id: UUID, with provider: Provider, on database: any Database) async throws -> Provider
    func delete(_ id: UUID, on database: any Database) async throws -> Bool
}

public struct ProviderDAO: ProviderDAOProtocol {
    public init() {}
    
    public func findAll(on database: any FluentKit.Database) async throws -> [Provider] {
        let models = try await ProviderModel.query(on: database).all()
        return models.map { $0.toDomainModel() }
    }
    
    public func findById(_ id: UUID, on database: any FluentKit.Database) async throws -> Provider? {
        guard let model = try await ProviderModel.find(id, on: database) else {
            return nil
        }
        return model.toDomainModel()
    }
    
    public func findByName(_ name: String, on database: any Database) async throws -> Provider? {
        guard let model = try await ProviderModel.query(on: database)
            .filter(.name, .equal, name)
            .first() else {
            return nil
        }
        return model.toDomainModel()
    }
    
    public func create(_ provider: Provider, on database: any FluentKit.Database) async throws -> Provider {
        let model = provider.toModel()
        try await model.save(on: database)
        return model.toDomainModel()
    }
    
    public func update(_ id: UUID, with provider: Provider, on database: any FluentKit.Database) async throws -> Provider {
        guard let model = try await ProviderModel.find(id, on: database) else {
            throw DAOError.notFound("Provider not found")
        }
        
        model.name = provider.name
        model.nit = provider.nit
        model.email = provider.email
        model.address = provider.address
        model.phone = provider.phone
        
        try await model.save(on: database)
        return model.toDomainModel()
    }
    
    public func delete(_ id: UUID, on database: any FluentKit.Database) async throws -> Bool {
        guard let model = try await ProviderModel.find(id, on: database) else {
            return false
        }
        
        try await model.delete(on: database)
        return true
    }
}
