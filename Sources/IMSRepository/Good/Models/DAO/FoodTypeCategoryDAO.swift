//
//  FoodTypeCategoryDAO.swift
//  server
//
//  Created by Mario Rúa on 23/07/25.
//
import Fluent
import IMSDomain

public protocol FoodTypeCategoryDAOProtocol: Sendable {
    func findAll(on database: any Database) async throws -> [FoodTypeCategory]
    func findById(_ id: UUID, on database: any Database) async throws -> FoodTypeCategory?
    func findByName(_ name: String, on database: any Database) async throws -> FoodTypeCategory?
    func create(_ category: FoodTypeCategory, on database: any Database) async throws -> FoodTypeCategory
    func update(_ id: UUID, with category: FoodTypeCategory, on database: any Database) async throws -> FoodTypeCategory
    func delete(_ id: UUID, on database: any Database) async throws -> Bool
}

public struct FoodTypeCategoryDAO: FoodTypeCategoryDAOProtocol {
    public init() {}
    
    public func findAll(on database: any FluentKit.Database) async throws -> [FoodTypeCategory] {
        let models = try await FoodTypeCategoryModel.query(on: database).all()
                return models.map { $0.toDomainModel() }
    }
    
    public func findById(_ id: UUID, on database: any FluentKit.Database) async throws -> FoodTypeCategory? {
        guard let model = try await FoodTypeCategoryModel.find(id, on: database) else {
            return nil
        }
        return model.toDomainModel()
    }
    
    public func findByName(_ name: String, on database: any Database) async throws -> FoodTypeCategory? {
        guard let model = try await FoodTypeCategoryModel.query(on: database)
            .filter(.name, .equal, name)
            .first() else {
            return nil
        }
        return model.toDomainModel()
    }
    
    public func create(_ category: FoodTypeCategory, on database: any FluentKit.Database) async throws -> FoodTypeCategory {
        let model = category.toModel()
        try await model.save(on: database)
        return model.toDomainModel()
    }
    
    public func update(_ id: UUID, with category: FoodTypeCategory, on database: any FluentKit.Database) async throws -> FoodTypeCategory {
        guard let model = try await FoodTypeCategoryModel.find(id, on: database) else {
            throw DAOError.notFound("Category not found")
        }
        
        model.name = category.name
        try await model.save(on: database)
        return model.toDomainModel()
    }
    
    public func delete(_ id: UUID, on database: any FluentKit.Database) async throws -> Bool {
        guard let model = try await MeasurementTypeModel.find(id, on: database) else {
            return false
        }
        
        try await model.delete(on: database)
        return true
    }
}
