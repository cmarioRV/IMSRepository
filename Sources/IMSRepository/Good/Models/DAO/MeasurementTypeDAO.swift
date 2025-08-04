//
//  MeasurementTypeDAO.swift
//  server
//
//  Created by Mario Rúa on 23/07/25.
//
import Fluent
import IMSDomain

public protocol MeasurementTypeDAOProtocol: Sendable {
    func findAll(on database: any Database) async throws -> [MeasurementType]
    func findById(_ id: UUID, on database: any Database) async throws -> MeasurementType?
    func findByName(_ name: String, on database: any FluentKit.Database) async throws -> MeasurementType?
    func findUnits(for typeId: UUID, on database: any Database) async throws -> [MeasurementUnit]
    func create(_ measurementType: MeasurementType, on database: any Database) async throws -> MeasurementType
    func update(_ id: UUID, with measurementType: MeasurementType, on database: any Database) async throws -> MeasurementType
    func delete(_ id: UUID, on database: any Database) async throws -> Bool
}

public struct MeasurementTypeDAO: MeasurementTypeDAOProtocol {
    public init() {}
    
    public func findAll(on database: any FluentKit.Database) async throws -> [MeasurementType] {
        let models = try await MeasurementTypeModel.query(on: database).all()
        return models.map { $0.toDomainModel() }
    }
    
    public func findById(_ id: UUID, on database: any FluentKit.Database) async throws -> MeasurementType? {
        guard let model = try await MeasurementTypeModel.find(id, on: database) else {
            return nil
        }
        return model.toDomainModel()
    }
    
    public func findByName(_ name: String, on database: any FluentKit.Database) async throws -> MeasurementType? {
        guard let model = try await MeasurementTypeModel.query(on: database)
            .filter(.name, .equal, name)
            .first() else {
            return nil
        }
        return model.toDomainModel()
    }
    
    public func findUnits(for typeId: UUID, on database: any Database) async throws -> [MeasurementUnit] {
        guard let model = try await MeasurementTypeModel.find(typeId, on: database) else {
            return []
        }
        
        try await model.$units.load(on: database)
        var units: [MeasurementUnit] = []
        
        for unitModel in model.units {
            let unit = unitModel.toDomainModel()
            units.append(unit)
        }
        
        return units
    }
    
    public func create(_ measurementType: MeasurementType, on database: any FluentKit.Database) async throws -> MeasurementType {
        let model = measurementType.toModel()
        try await model.save(on: database)
        return model.toDomainModel()
    }
    
    public func update(_ id: UUID, with measurementType: MeasurementType, on database: any FluentKit.Database) async throws -> MeasurementType {
        guard let model = try await MeasurementTypeModel.find(id, on: database) else {
            throw DAOError.notFound("Measurement type not found")
        }
        
        model.name = measurementType.name
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
