//
//  InvoiceDataTransferObjects.swift
//  server
//
//  Created by Mario Rúa on 10/07/25.
//
import Vapor
import OpenAI
import IMSDomain

struct InvoiceItemDTO: Content {
    var description: String?
    var quantity: Double?
    var unitPrice: Double?
}

struct ChatMessageDTO: Content {
    let role: String
    let content: String
}

struct InvoiceJsonResponseDTO: Content, JSONSchemaConvertible {
    var purchaseDate: String?
    var goods: [InvoiceGood]
    var provider: Provider?
    
    static let example: Self = {
        .init(purchaseDate: "14/07/2025", goods: [.init(name: "Cebolla", quantity: 2, unit: "kg", unitPrice: 12000, total: 24000)], provider: .init(id: UUID.generateRandom(), createdAt: .now, updatedAt: .now, name: "Makro", nit: "901000000", email: "email@makro.com", address: "Cra 77 # 77 77", phone: "6045555555"))
    }()
}

extension InvoiceJsonResponseDTO {
    func toDomainModel() -> Invoice {
        .init(purchaseDate: purchaseDate,
              goods: goods,
              provider: provider)
    }
}

struct ProviderDTO: Content {
    var id: UUID?
    var createdAt: Date?
    var updatedAt: Date?
    var name: String
    var nit: String?
    var email: String?
    var address: String?
    var phone: String?
}

//extension ProviderDTO: DomainModelConvertible {
//    func toDomainModel() -> Provider {
//        .init(id: id,
//              createdAt: createdAt,
//              updatedAt: updatedAt,
//              name: name,
//              nit: nit,
//              email: email,
//              address: address,
//              phone: phone)
//    }
//}
//
//extension Provider: DTOConvertible {
//    func toDTO() -> ProviderDTO {
//        .init(id: id,
//              createdAt: createdAt,
//              updatedAt: updatedAt,
//              name: name,
//              nit: nit,
//              email: email,
//              address: address,
//              phone: phone)
//    }
//}
