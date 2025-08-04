//
//  GoodFieldsModel.swift
//  server
//
//  Created by Mario Rúa on 26/07/25.
//
import Foundation
import VaporFirestore
import IMSDomain

protocol FirestoreFieldsModel: Codable, Sendable {

}

struct GoodFieldsModel: FirestoreFieldsModel {
    @Firestore.StringValue
    var name: String
    
    @Firestore.NullableValue<Firestore.StringValue>
    var description: String?
    
    @Firestore.MapValue
    var measure_unit: MeasurementUnitFieldsModel
    
    @Firestore.DoubleValue
    var price: Double
    
    @Firestore.DoubleValue
    var quantity: Double
    
    @Firestore.MapValue
    var category: FoodTypeCategoryModelFields
    
    @Firestore.ArrayValue
    var providers: [Firestore.MapValue<ProviderFieldsModel>]
}

extension GoodFieldsModel: FirestoreDomainModelConvertible {
    func toDomainModel() -> Good {
        .init(id: nil,
              createdAt: nil,
              updatedAt: nil,
              name: name,
              description: description,
              unit: measure_unit.toDomainModel(),
              price: price,
              quantity: quantity,
              category: category.toDomainModel(),
              providers: providers.map({ $0.wrappedValue.toDomainModel() }))
    }
}
