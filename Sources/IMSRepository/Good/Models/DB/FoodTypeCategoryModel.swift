//
//  CategoryDAO.swift
//  server
//
//  Created by Mario Rúa on 18/07/25.
//
import Vapor
import Fluent
import IMSDomain

public final class FoodTypeCategoryModel: DatabaseModel, @unchecked Sendable  {
    public static let schema = Create_20250718.schema
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: Create_20250718.name)
    var name: String
    
    @Children(for: \.$category)
    var goods: [GoodModel]
    
    public init() {
        
    }
    
    public init(id: UUID?, name: String) {
        self.id = id
        self.name = name
    }
}

public extension FoodTypeCategoryModel {
    public enum Create_20250718 {
        public static let schema = "food_type_categories"
        
        public static let name: FieldKey = .name
    }
}

extension FoodTypeCategoryModel: DomainModelConvertible {
    func toDomainModel() -> FoodTypeCategory {
        .init(id: id, name: name)
    }
}

extension FoodTypeCategory: ModelConvertible {
    public func toModel() -> FoodTypeCategoryModel {
        .init(id: id, name: name)
    }
}

extension FoodTypeCategory: FirestoreConvertible {
    func toFirestoreModel() ->  FoodTypeCategoryModelFields {
        .init(name: name)
    }
}
