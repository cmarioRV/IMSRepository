//
//  ProviderFieldsModel.swift
//  server
//
//  Created by Mario Rúa on 26/07/25.
//
import Foundation
import VaporFirestore
import IMSDomain

struct ProviderFieldsModel: FirestoreFieldsModel {
    @Firestore.StringValue
    var name: String
    
    @Firestore.NullableValue<Firestore.StringValue>
    var nit: String?
    
    @Firestore.NullableValue<Firestore.StringValue>
    var email: String?
    
    @Firestore.NullableValue<Firestore.StringValue>
    var address: String?
    
    @Firestore.NullableValue<Firestore.StringValue>
    var phone: String?
}

extension ProviderFieldsModel: FirestoreDomainModelConvertible {
    func toDomainModel() -> Provider {
        .init(id: nil,
              createdAt: nil,
              updatedAt: nil,
              name: name,
              nit: nit,
              email: email,
              address: address,
              phone: phone)
    }
}

extension ProviderFieldsModel: Equatable {
    static func == (lhs: ProviderFieldsModel, rhs: ProviderFieldsModel) -> Bool {
        return lhs.name == rhs.name
    }
}

extension ProviderFieldsModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
