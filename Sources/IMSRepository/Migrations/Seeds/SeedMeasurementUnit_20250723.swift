//
//  SeedMeasurementUnit_20250723.swift
//  server
//
//  Created by Mario Rúa on 23/07/25.
//

import Fluent

enum Dimensions: String {
    case weight = "Peso"
    case volume = "Volumen"
    case quantity = "Cantidad"
    case length = "Longitud"
}

extension MeasurementUnitModel {
    struct Seed: AsyncMigration {
        func prepare(on database: any FluentKit.Database) async throws {
            
            guard let weightResultType = try await MeasurementTypeModel.query(on: database)
                .filter(\MeasurementTypeModel.$name, .equal, Dimensions.weight.rawValue)
                .first() else {
                return
            }
            
            guard let volumeResultType = try await MeasurementTypeModel.query(on: database)
                .filter(\MeasurementTypeModel.$name, .equal, Dimensions.volume.rawValue)
                .first() else {
                    return
                }
            
            guard let quantityResultType = try await MeasurementTypeModel.query(on: database)
                .filter(\MeasurementTypeModel.$name, .equal, Dimensions.quantity.rawValue)
                .first() else {
                    return
                }
            
            guard let lengthResultType = try await MeasurementTypeModel.query(on: database)
                .filter(\MeasurementTypeModel.$name, .equal, Dimensions.length.rawValue)
                .first() else {
                    return
                }
            
            let measurementUnits: [MeasurementUnitModel] = [
                .init(id: .generateRandom(), name: "Litro", abbreviation: "lt", factor: 1000, measurementTypeId: try volumeResultType.requireID()),
                .init(id: .generateRandom(), name: "Gramo", abbreviation: "g", factor: 1, measurementTypeId: try weightResultType.requireID()),
                .init(id: .generateRandom(), name: "Libra", abbreviation: "lb", factor: 453, measurementTypeId: try weightResultType.requireID()),
                .init(id: .generateRandom(), name: "Kilogramo", abbreviation: "kg", factor: 1000, measurementTypeId: try weightResultType.requireID()),
                .init(id: .generateRandom(), name: "Unidad", abbreviation: "und", factor: 1, measurementTypeId: try quantityResultType.requireID()),
                .init(id: .generateRandom(), name: "Centimetro", abbreviation: "cm", factor: 1, measurementTypeId: try lengthResultType.requireID()),
                .init(id: .generateRandom(), name: "Metro", abbreviation: "m", factor: 100, measurementTypeId: try lengthResultType.requireID())
            ]
            
            for measurementUnit in measurementUnits {
                try await measurementUnit.save(on: database)
            }
        }
        
        func revert(on database: any FluentKit.Database) async throws {
            try await MeasurementUnitModel.query(on: database).delete()
        }
    }
}
