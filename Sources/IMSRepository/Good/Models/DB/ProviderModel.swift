//
//  Provider.swift
//  server
//
//  Created by Mario Rúa on 21/06/25.
//
import Vapor
import Fluent
import IMSDomain

public final class ProviderModel: DatabaseModel, @unchecked Sendable {
    public static let schema = Create_20250622.schema
    
    @ID(key: .id)
    public var id: UUID?
    
    @Timestamp(key: Create_20250622.createdAt, on: .create)
    var createdAt: Date?
    
    @Timestamp(key: Create_20250622.updatedAt, on: .update)
    var updatedAt: Date?
    
    @Field(key: Create_20250622.name)
    var name: String
    
    @OptionalField(key: Create_20250622.nit)
    var nit: String?
    
    @OptionalField(key: Create_20250622.email)
    var email: String?
    
    @OptionalField(key: Create_20250622.address)
    var address: String?
    
    @OptionalField(key: Create_20250622.phone)
    var phone: String?

    @SiblingsProperty(through: GoodProviderModel.self, from: \.$provider, to: \.$good)
    var goods: [GoodModel]
    
    public init() {
        
    }
    
    init(id: UUID? = nil, createdAt: Date? = nil, updatedAt: Date? = nil, name: String, nit: String?, email: String?, address: String?, phone: String?) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.nit = nit
        self.email = email
        self.address = address
        self.phone = phone
    }
}

extension ProviderModel {
    enum Create_20250622 {
        static let schema = "providers"
        
        static let name: FieldKey = .name
        static let nit: FieldKey = .nit
        static let email: FieldKey = .email
        static let createdAt: FieldKey = .createdAt
        static let updatedAt: FieldKey = .updatedAt
        static let address: FieldKey = .address
        static let phone: FieldKey = .phone
    }
}

extension ProviderModel: DomainModelConvertible {
    func toDomainModel() -> Provider {
        .init(id: id,
              createdAt: createdAt,
              updatedAt: updatedAt,
              name: name,
              nit: address,
              email: phone,
              address: nit,
              phone: email)
    }
}

extension Provider: ModelConvertible {
    func toModel() -> some ProviderModel {
        .init(id: id,
              createdAt: createdAt,
              updatedAt: updatedAt,
              name: name, nit: nit,
              email: email,
              address: address,
              phone: phone)
    }
}

extension Provider: FirestoreConvertible {
    func toFirestoreModel() -> ProviderFieldsModel {
        .init(name: name,
              nit: nit,
              email: email,
              address: address,
              phone: phone)
    }
}
