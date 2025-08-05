//
//  CategoryCreate_20250718.swift
//  server
//
//  Created by Mario Rúa on 18/07/25.
//
import Fluent

extension FoodTypeCategoryModel {
    struct Create: AsyncMigration {
        func prepare(on database: any FluentKit.Database) async throws {
            try await database.schema(FoodTypeCategoryModel.schema)
                .id()
                .field(FoodTypeCategoryModel.Create_20250718.name, .string, .required)
                .create()
        }
        
        func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(FoodTypeCategoryModel.schema).delete()
        }
    }
}
