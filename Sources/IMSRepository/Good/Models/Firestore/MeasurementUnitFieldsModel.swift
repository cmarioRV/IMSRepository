//
//  MeasurementUnitFieldsModel.swift
//  server
//
//  Created by Mario Rúa on 26/07/25.
//
import Foundation
import VaporFirestore
import IMSDomain

struct MeasurementUnitFieldsModel: FirestoreFieldsModel {
    @Firestore.StringValue
    var name: String
    
    @Firestore.StringValue
    var abbreviation: String
    
    @Firestore.DoubleValue
    var factor: Double
    
    @Firestore.MapValue
    var measurementType: MeasurementTypeFieldsModel
}

extension MeasurementUnitFieldsModel: FirestoreDomainModelConvertible {
    func toDomainModel() -> MeasurementUnit {
        .init(id: nil,
              name: name,
              abbreviation: abbreviation,
              factor: factor,
              measurementType: measurementType.toDomainModel())
    }
}
