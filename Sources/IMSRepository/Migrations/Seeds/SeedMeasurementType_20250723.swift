//
//  SeedMeasurementType_20250723.swift
//  server
//
//  Created by Mario Rúa on 23/07/25.
//

import Fluent

extension MeasurementTypeModel {
    struct Seed: AsyncMigration {
        func prepare(on database: any FluentKit.Database) async throws {
            
            let measurementTypes: [MeasurementTypeModel] = [
                .init(id: .generateRandom(), name: "Peso"),
                .init(id: .generateRandom(), name: "Volumen"),
                .init(id: .generateRandom(), name: "Cantidad"),
                .init(id: .generateRandom(), name: "Longitud")
            ]
            
            for measurementType in measurementTypes {
                try await measurementType.save(on: database)
            }
        }
        
        func revert(on database: any FluentKit.Database) async throws {
            try await MeasurementTypeModel.query(on: database).delete()
        }
    }
}
