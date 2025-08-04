//
//  MeasurementUnitCreate_20250720.swift
//  server
//
//  Created by Mario Rúa on 20/07/25.
//
import Fluent

extension MeasurementUnitModel {
    struct Create: AsyncMigration {
        func prepare(on database: any FluentKit.Database) async throws {
            try await database.schema(MeasurementUnitModel.schema)
                .id()
                .field(MeasurementUnitModel.Create_20250718.name, .string, .required)
                .field(MeasurementUnitModel.Create_20250718.abbreviation, .string, .required)
                .field(MeasurementUnitModel.Create_20250718.factor, .double, .required)
                .field(MeasurementUnitModel.Create_20250718.measurementTypeId, .uuid, .required, .references(MeasurementTypeModel.Create_20250720.schema, FieldKey.id, onDelete: .cascade))
                .unique(on: MeasurementUnitModel.Create_20250718.name)
                .unique(on: MeasurementUnitModel.Create_20250718.abbreviation)
                .create()
        }
        
        func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(MeasurementUnitModel.schema).delete()
        }
    }
}
