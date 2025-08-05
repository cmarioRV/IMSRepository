//
//  MeasurementTypeCreate_20250720.swift
//  server
//
//  Created by Mario Rúa on 20/07/25.
//
import Fluent

extension MeasurementTypeModel {
    struct Create: AsyncMigration {
        func prepare(on database: any FluentKit.Database) async throws {
            try await database.schema(MeasurementTypeModel.schema)
                .id()
                .field(MeasurementTypeModel.Create_20250720.name, .string, .required)
                .unique(on: MeasurementTypeModel.Create_20250720.name)
                .create()
        }
        
        func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(MeasurementTypeModel.schema).delete()
        }
    }
}
