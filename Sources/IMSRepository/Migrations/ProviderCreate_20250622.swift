//
//  ProviderCreate_20250622.swift
//  server
//
//  Created by Mario Rúa on 22/06/25.
//

import Fluent

extension ProviderModel {
    struct Create: AsyncMigration {
        func prepare(on database: any FluentKit.Database) async throws {
            try await database.schema(ProviderModel.schema)
                .id()
                .field(ProviderModel.Create_20250622.createdAt, .datetime)
                .field(ProviderModel.Create_20250622.updatedAt, .datetime)
                .field(ProviderModel.Create_20250622.name, .string, .required)
                .field(ProviderModel.Create_20250622.nit, .string)
                .field(ProviderModel.Create_20250622.email, .string)
                .field(ProviderModel.Create_20250622.address, .string, .required)
                .field(ProviderModel.Create_20250622.phone, .string, .required)
                .create()
        }
        
        func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(ProviderModel.schema).delete()
        }
    }
}
