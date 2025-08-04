//
//  GoodDAO.swift
//  server
//
//  Created by Mario Rúa on 23/07/25.
//
import Fluent
import IMSDomain

enum GoodDAOError: Error {
    case notFound
}

public protocol GoodDAOProtocol: Sendable {
    func findAll(on database: any Database) async throws -> [Good]
    func findById(_ id: UUID, on database: any Database) async throws -> Good?
    func findByName(_ name: String, on database: any Database) async throws -> Good?
    func findByPrice(minPrice: Double, maxPrice: Double, on database: any Database) async throws -> [Good]
    func create(_ good: Good, on database: any Database) async throws -> Good
    @discardableResult
    func update(_ id: UUID, with dto: Good, on database: any Database) async throws -> Good
    func delete(_ id: UUID, on database: any Database) async throws -> Bool
}

public struct GoodDAO: GoodDAOProtocol {
    public init() {}
    
    public func findAll(on database: any FluentKit.Database) async throws -> [Good] {
        let models = try await GoodModel.getAll(on: database)
        let result = try await withThrowingTaskGroup(of: Good.self) { group in
            var goods: [Good] = []
            for model in models {
                group.addTask {
                    model.toDomainModel()
                }
            }
            
            while let unit = try await group.next() {
                goods.append(unit)
            }
            
            return goods
        }
        
        return result
    }
    
    public func findById(_ id: UUID, on database: any FluentKit.Database) async throws -> Good? {
        guard let model = try await GoodModel.get(withId: id, on: database) else {
            return nil
        }
        return model.toDomainModel()
    }
    
    public func findByName(_ name: String, on database: any Database) async throws -> Good? {
        let model = try await GoodModel.get(withName: name, on: database)
        
        guard let model = model else {
            return nil
        }
        
        return model.toDomainModel()
    }
    
    public func findByPrice(minPrice: Double, maxPrice: Double, on database: any Database) async throws -> [Good] {
        let models = try await GoodModel.query(on: database)
            .filter(\.$price, .greaterThanOrEqual, minPrice)
            .filter(\.$price, .lessThanOrEqual, maxPrice)
            .with(\.$measurementUnit) { measurementUnit in
                measurementUnit.with(\.$measurementType)
            }
            .with(\.$category)
            .with(\.$providers)
            .all()
        
        return models.map { $0.toDomainModel() }
    }
    
    public func create(_ good: Good, on database: any FluentKit.Database) async throws -> Good {
        let model = good.toModel()
        try await model.save(on: database)
        guard let good = try await findById(model.id!, on: database) else {
            throw GoodDAOError.notFound
        }
        
        return good
    }
    
    public func update(_ id: UUID, with good: Good, on database: any FluentKit.Database) async throws -> Good {
        guard let model = try await GoodModel.find(id, on: database),
              let goodCategoryId = good.category.id,
              let unitId = good.unit.id else {
            throw GoodDAOError.notFound
        }
        
        model.name = good.name
        model.description = good.description
        model.quantity = good.quantity
        model.$category.id = goodCategoryId
        model.$measurementUnit.id = unitId
        model.price = good.price
        
        try await model.save(on: database)
        
        guard let good = try await findById(id, on: database) else {
            throw GoodDAOError.notFound
        }
        return good
    }
    
    public func delete(_ id: UUID, on database: any FluentKit.Database) async throws -> Bool {
        guard let model = try await GoodModel.find(id, on: database) else {
            return false
        }
        
        try await model.delete(on: database)
        return true
    }
}
