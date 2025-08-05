//
//  GoodCreate_20250622.swift
//  server
//
//  Created by Mario Rúa on 22/06/25.
//
import Fluent

extension GoodModel {
    struct Create: AsyncMigration {
        func prepare(on database: any FluentKit.Database) async throws {
            try await database.schema(GoodModel.schema)
                .id()
                .field(GoodModel.Create_20250622.createdAt, .datetime)
                .field(GoodModel.Create_20250622.updatedAt, .datetime)
                .field(GoodModel.Create_20250622.name, .string, .required)
                .field(GoodModel.Create_20250622.description, .string)
                .field(GoodModel.Create_20250622.unitId, .uuid, .required, .references(MeasurementUnitModel.Create_20250718.schema, FieldKey.id))
                .field(GoodModel.Create_20250622.price, .double, .required)
                .field(GoodModel.Create_20250622.quantity, .double, .required)
                .field(GoodModel.Create_20250622.categoryId, .uuid, .required, .references(FoodTypeCategoryModel.Create_20250718.schema, FieldKey.id))
                .create()
        }
        
        func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(GoodModel.schema).delete()
        }
    }
}
