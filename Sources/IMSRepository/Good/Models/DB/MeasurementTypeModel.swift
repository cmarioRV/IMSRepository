//
//  MeasurementTypeDAO.swift
//  server
//
//  Created by Mario Rúa on 20/07/25.
//
import Vapor
import Fluent
import IMSDomain

public final class MeasurementTypeModel: DatabaseModel, @unchecked Sendable {
    public static let schema = Create_20250720.schema
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: Create_20250720.name)
    public var name: String
    
    @Children(for: \.$measurementType)
    var units: [MeasurementUnitModel]
    
    public init() {
        
    }
    
    public init(id: UUID?, name: String) {
        self.id = id
        self.name = name
    }
}

extension MeasurementTypeModel {
    public enum Create_20250720 {
        public static let schema = "measurement_types"
        
        public static let name: FieldKey = .name
    }
}

extension MeasurementTypeModel: DomainModelConvertible {
    func toDomainModel() -> MeasurementType {
        .init(id: id, name: name)
    }
}

extension MeasurementType: ModelConvertible {
    public func toModel() -> MeasurementTypeModel {
        .init(id: id, name: name)
    }
}

extension MeasurementType: FirestoreConvertible {
    func toFirestoreModel() -> MeasurementTypeFieldsModel {
        .init(name: name)
    }
}
