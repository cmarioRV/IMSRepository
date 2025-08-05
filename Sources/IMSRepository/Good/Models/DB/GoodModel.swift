//
//  Item.swift
//  server
//
//  Created by Mario Rúa on 21/06/25.
//
import Vapor
import Fluent
import FluentKit
import IMSDomain
import VaporFirestore

public final class GoodModel: DatabaseModel, @unchecked Sendable {
    public static let schema = Create_20250622.schema
    
    @ID(key: .id)
    public var id: UUID?
    
    @Timestamp(key: Create_20250622.createdAt, on: .create)
    var createdAt: Date?
    
    @Timestamp(key: Create_20250622.updatedAt, on: .update)
    var updatedAt: Date?
    
    @Field(key: Create_20250622.name)
    var name: String
    
    @OptionalField(key: Create_20250622.description)
    var description: String?
    
    @Parent(key: Create_20250622.unitId)
    var measurementUnit: MeasurementUnitModel
    
    @Field(key: Create_20250622.price)
    var price: Double
    
    @Field(key: Create_20250622.quantity)
    var quantity: Double
    
    @Parent(key: Create_20250622.categoryId)
    var category: FoodTypeCategoryModel

    @SiblingsProperty(through: GoodProviderModel.self, from: \.$good, to: \.$provider)
    var providers: [ProviderModel]
    
    public init() {
        
    }
    
    init(id: UUID?, createdAt: Date?, updatedAt: Date?, name: String, description: String?, measurementUnitId: MeasurementUnitModel.IDValue, price: Double, quantity: Double, categoryId: FoodTypeCategoryModel.IDValue) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.description = description
        self.$measurementUnit.id = measurementUnitId
        self.price = price
        self.quantity = quantity
        self.$category.id = categoryId
    }
}

extension GoodModel {
     enum Create_20250622 {
        static let schema = "goods"
        
         static let name: FieldKey = .name
         static let createdAt: FieldKey = .createdAt
         static let updatedAt: FieldKey = .updatedAt
         static let quantity: FieldKey = .quantity
         static let providers: FieldKey = .providers
         static let price: FieldKey = .price
         static let description: FieldKey = .description
         static let categoryId: FieldKey = .categoryId
         static let unitId: FieldKey = .unitId
    }
}

extension Good: ModelConvertible {
    func toModel() -> GoodModel {
        .init(id: self.id,
              createdAt: createdAt,
              updatedAt: updatedAt,
              name: name,
              description: description,
              measurementUnitId: unit.id!,
              price: price,
              quantity: quantity,
              categoryId: category.id!)
    }
}

extension GoodModel: DomainModelConvertible {
    func toDomainModel() -> Good {
        .init(id: id,
              createdAt: createdAt,
              updatedAt: updatedAt,
              name: name,
              description: description,
              unit: measurementUnit.toDomainModel(),
              price: price,
              quantity: quantity,
              category: category.toDomainModel(),
              providers: providers.map { $0.toDomainModel() })
    }
}

extension Good: FirestoreConvertible {
    func toFirestoreModel() -> GoodFieldsModel {
        .init(name: name,
              description: description,
              measure_unit: unit.toFirestoreModel(),
              price: price,
              quantity: quantity,
              category: category.toFirestoreModel(),
              providers: providers.map { Firestore.MapValue(wrappedValue: $0.toFirestoreModel()) })
    }
}

extension GoodModel {
    static func getAll(on database: any Database) async throws -> [GoodModel] {
        let model = try await GoodModel.query(on: database)
            .with(\.$measurementUnit) { measurementUnit in
                measurementUnit.with(\.$measurementType)
            }
            .with(\.$category)
            .with(\.$providers)
            .all()
        
        return model
    }
    
    static func get(withId id: UUID, on database: any Database) async throws -> GoodModel? {
        let model = try await GoodModel.query(on: database)
            .filter(\.$id == id)
            .with(\.$measurementUnit) { measurementUnit in
                measurementUnit.with(\.$measurementType)
            }
            .with(\.$category)
            .with(\.$providers)
            .first()
        
        return model
    }
    
    static func get(withName name: String, on database: any Database) async throws -> GoodModel? {
        let model = try await GoodModel.query(on: database)
            .filter(\.$name == name)
            .with(\.$measurementUnit) { measurementUnit in
                measurementUnit.with(\.$measurementType)
            }
            .with(\.$category)
            .with(\.$providers)
            .first()
        
        return model
    }
}
