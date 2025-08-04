//
//  MeasurementUnitDAO.swift
//  server
//
//  Created by Mario Rúa on 23/07/25.
//
import Fluent
import IMSDomain

enum MeasurementUnitDAOError: Error {
    case notFound
}

public protocol MeasurementUnitDAOProtocol: Sendable {
    func findAll(on database: any Database) async throws -> [MeasurementUnit]
    func findById(_ id: UUID, on database: any Database) async throws -> MeasurementUnit?
    func findByName(_ name: String, on database: any Database) async throws -> MeasurementUnit?
    func save(_ unit: MeasurementUnit, on database: any FluentKit.Database) async throws -> MeasurementUnit
    func delete(_ id: UUID, on database: any Database) async throws -> Bool
}

public struct MeasurementUnitDAO: MeasurementUnitDAOProtocol {
    public init() {}
    
    public func findAll(on database: any FluentKit.Database) async throws -> [MeasurementUnit] {
        let models = try await MeasurementUnitModel.query(on: database)
            .with(\.$measurementType)
            .all()
        
        let result = try await withThrowingTaskGroup(of: MeasurementUnit.self) { group in
            var units: [MeasurementUnit] = []
            for model in models {
                group.addTask {
                    model.toDomainModel()
                }
            }
            
            while let unit = try await group.next() {
                units.append(unit)
            }
            
            return units
        }
        
        return result
    }
    
    public func findById(_ id: UUID, on database: any FluentKit.Database) async throws -> MeasurementUnit? {
        guard let model = try await MeasurementUnitModel.find(id, on: database) else {
            return nil
        }
        
        try await model.$measurementType.load(on: database)
        return model.toDomainModel()
    }
    
    public func findByName(_ name: String, on database: any Database) async throws -> MeasurementUnit? {
        guard let model = try await MeasurementUnitModel.query(on: database)
            .filter(.name, .equal, name)
            .with(\.$measurementType)
            .first() else {
            return nil
        }
        
        return model.toDomainModel()
    }
    
    public func save(_ unit: MeasurementUnit, on database: any FluentKit.Database) async throws -> MeasurementUnit {
        let existingUnit = try await MeasurementUnitModel.query(on: database)
            .filter(.name, .equal, unit.name)
            .with(\.$measurementType)
            .first()
            
        let storedUnit: MeasurementUnit
        
        if let existingUnit = existingUnit {
            storedUnit = existingUnit.toDomainModel()
        } else {
            storedUnit = try await create(unit, on: database)
        }
        
        return storedUnit
    }
    
    public func delete(_ id: UUID, on database: any FluentKit.Database) async throws -> Bool {
        guard let model = try await MeasurementUnitModel.find(id, on: database) else {
            return false
        }
        
        try await model.delete(on: database)
        return true
    }
}

extension MeasurementUnitDAO {
    private func create(_ unit: MeasurementUnit, on database: any FluentKit.Database) async throws -> MeasurementUnit {
        let model = unit.toModel()
        try await model.save(on: database)
        guard let unit = try await findById(model.id!, on: database) else {
            throw MeasurementUnitDAOError.notFound
        }
        
        return unit
    }
}
