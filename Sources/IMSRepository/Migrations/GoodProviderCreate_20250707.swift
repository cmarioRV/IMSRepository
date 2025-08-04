//
//  GoodProviderCreate_20250707.swift
//  server
//
//  Created by Mario Rúa on 7/07/25.
//

import Fluent

extension GoodProviderModel {
    struct Create: AsyncMigration {
        func prepare(on database: any FluentKit.Database) async throws {
            try await database.schema(GoodProviderModel.schema)
                .id()
                .field(GoodProviderModel.Create_20250707.goodId,
                       .uuid,
                       .required,
                       .references(GoodModel.schema,
                                   FieldKey.id))
                .field(GoodProviderModel.Create_20250707.providerId,
                       .uuid,
                       .required,
                       .references(ProviderModel.schema,
                                   FieldKey.id))
                .create()
        }
        
        func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(GoodProviderModel.schema).delete()
        }
    }
}
