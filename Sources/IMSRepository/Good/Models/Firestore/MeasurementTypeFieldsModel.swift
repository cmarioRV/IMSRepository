//
//  MeasurementTypeFieldsModel.swift
//  server
//
//  Created by Mario Rúa on 26/07/25.
//
import Foundation
import VaporFirestore
import IMSDomain

struct MeasurementTypeFieldsModel: FirestoreFieldsModel {
    @Firestore.StringValue
    var name: String
}

extension MeasurementTypeFieldsModel: FirestoreDomainModelConvertible {
    func toDomainModel() -> MeasurementType {
        .init(id: nil, name: name)
    }
}
