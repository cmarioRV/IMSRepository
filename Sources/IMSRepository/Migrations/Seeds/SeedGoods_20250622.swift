
//
//  SeedGoods_20250622.swift
//  server
//
//  Created by Mario Rúa on 22/06/25.
//
import Fluent

extension GoodModel {
    struct Seed: AsyncMigration {
        func prepare(on database: any FluentKit.Database) async throws {
            
            let goods: [GoodModel] = [
                .init(id: .generateRandom(),
                      createdAt: .now,
                      updatedAt: .now,
                      name: "Test",
                      description: "Test",
                      measurementUnitId: .generateRandom(),
                      price: 1,
                      quantity: 1,
                      categoryId: .generateRandom())
            ]
            
            for good in goods {
                try await good.save(on: database)
            }
        }
        
        func revert(on database: any FluentKit.Database) async throws {
            try await GoodModel.query(on: database).delete()
        }
    }
}
