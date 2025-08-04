//
//  SeedFoodCategories_20250724.swift
//  server
//
//  Created by Mario Rúa on 24/07/25.
//

import Fluent

extension FoodTypeCategoryModel {
    struct Seed: AsyncMigration {
        func prepare(on database: any Database) async throws {
            
            let categories: [FoodTypeCategoryModel] = [
                .init(id: .generateRandom(), name: "Carnes"),
                .init(id: .generateRandom(), name: "Mariscos"),
                .init(id: .generateRandom(), name: "Frutas y Vegetales"),
                .init(id: .generateRandom(), name: "Lacteos"),
                .init(id: .generateRandom(), name: "Secos"),
                .init(id: .generateRandom(), name: "Panaderia"),
                .init(id: .generateRandom(), name: "Especias"),
                .init(id: .generateRandom(), name: "Grasas y Aceites")
            ]
            
            for category in categories {
                try await category.save(on: database)
            }
        }
        
        func revert(on database: any FluentKit.Database) async throws {
            try await FoodTypeCategoryModel.query(on: database).delete()
        }
    }
}
