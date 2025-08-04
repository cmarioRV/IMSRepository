//
//  FoodTypeCategoryModelFields.swift
//  server
//
//  Created by Mario Rúa on 26/07/25.
//
import Foundation
import VaporFirestore
import IMSDomain

struct FoodTypeCategoryModelFields: FirestoreFieldsModel {
    @Firestore.StringValue
    var name: String
}

extension FoodTypeCategoryModelFields: FirestoreDomainModelConvertible {
    func toDomainModel() -> FoodTypeCategory {
        .init(id: nil, name: name)
    }
}
