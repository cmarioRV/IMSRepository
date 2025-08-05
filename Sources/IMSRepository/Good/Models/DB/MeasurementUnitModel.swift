//
//  MeasurementUnitModel.swift
//  server
//
//  Created by Mario Rúa on 18/07/25.
//

import Vapor
import Fluent
import IMSDomain

public final class MeasurementUnitModel: DatabaseModel, @unchecked Sendable {
    public static let schema = Create_20250718.schema
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: Create_20250718.name)
    var name: String
    
    @Field(key: Create_20250718.abbreviation)
    var abbreviation: String
    
    @Field(key: Create_20250718.factor)
    var factor: Double
    
    @Parent(key: Create_20250718.measurementTypeId)
    var measurementType: MeasurementTypeModel

    public init() { }
    
    init(id: UUID?, name: String, abbreviation: String, factor: Double, measurementTypeId: MeasurementTypeModel.IDValue) {
        self.id = id
        self.name = name
        self.abbreviation = abbreviation
        self.factor = factor
        self.$measurementType.id = measurementTypeId
    }
}

extension MeasurementUnitModel {
    enum Create_20250718 {
        static let schema = "measurement_units"
        
        static let name: FieldKey = .name
        static let abbreviation: FieldKey = .abbreviation
        static let factor: FieldKey = .factor
        static let measurementTypeId: FieldKey = .measurementTypeId
        static let goodId: FieldKey = .goodId
    }
}

extension MeasurementUnitModel: DomainModelConvertible {
    func toDomainModel() -> MeasurementUnit {
        .init(id: id,
              name: name,
              abbreviation: abbreviation,
              factor: factor,
              measurementType: $measurementType.wrappedValue.toDomainModel())
    }
}

extension MeasurementUnit: ModelConvertible {
    func toModel() -> some MeasurementUnitModel {
        .init(id: id,
              name: name,
              abbreviation: abbreviation,
              factor: factor,
              measurementTypeId: measurementType.id!)
    }
}

extension MeasurementUnit: FirestoreConvertible {
    func toFirestoreModel() -> MeasurementUnitFieldsModel {
        .init(name: name,
              abbreviation: abbreviation,
              factor: factor,
              measurementType: measurementType.toFirestoreModel())
    }
}
